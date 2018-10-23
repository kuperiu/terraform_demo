data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "template_file" "user_data" {
  template = "${file("userdata.tpl")}"
}

module "elb_sg" {
  source       = "../security_group"
  service_name = "${var.service_name}_elb"
  vpc_id       = "${var.vpc_id}"
  tags         = "${var.tags}"
  port         = "${var.elb_port}"
  cidr_blocks  = "${var.cidr_blocks}"
  associated   = "${var.associated}" 
  source_security_group_id = "${var.source_security_group_id}"
}

module "asg_sg" {
  source                   = "../security_group"
  service_name             = "${var.service_name}_asg"
  vpc_id                   = "${var.vpc_id}"
  tags                     = "${var.tags}"
  port                     = "${var.asg_port}"
  associated               = true
  source_security_group_id = "${module.elb_sg.id}"
}

####

#create a module
# ####
resource "aws_elb" "elb" {
  name            = "${var.service_name}"
  security_groups = ["${module.elb_sg.id}"]
  subnets = ["${split(",", var.internal_elb ? join(",", var.private_subnets) : join(",", var.public_subnets))}"]
  internal        = "${var.internal_elb}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
    target              = "${var.elb_health_check}"
  }

  listener {
    lb_port           = "${var.elb_port}"
    lb_protocol       = "tcp"
    instance_port     = "${var.asg_port}"
    instance_protocol = "tcp"
  }

  tags = "${var.tags}"
}


resource "aws_launch_configuration" "iam_launch_config" {
  name_prefix                 = "${var.service_name}"
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${module.asg_sg.id}"]
  associate_public_ip_address = "false"
  iam_instance_profile        = "${var.iam_instance_profile}"
  user_data                   = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  tags_asg_format = ["${null_resource.tags_as_list_of_maps.*.triggers}"]
}

resource "null_resource" "tags_as_list_of_maps" {
  count = "${length(keys(var.tags))}"

  triggers = "${map(
    "key", "${element(keys(var.tags), count.index)}",
    "value", "${element(values(var.tags), count.index)}",
    "propagate_at_launch", "true"
  )}"
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.service_name}"
  launch_configuration = "${aws_launch_configuration.iam_launch_config.name}"
  vpc_zone_identifier  = ["${split(",", true ? join(",", var.private_subnets) : join(",", var.public_subnets))}"]
  max_size             = "${var.desierd_instances}"
  min_size             = "${var.desierd_instances}"
  desired_capacity     = "${var.desierd_instances}"
  load_balancers       = ["${aws_elb.elb.name}"]
  health_check_type    = "ELB"

  tags = ["${concat(
      list(map("key", "Name", "value", var.service_name, "propagate_at_launch", true)),
      local.tags_asg_format
      )}"]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "basic_record" {
  zone_id = "${var.zone_id}"
  type    = "A"
  name    = "apime_${var.service_name}"

  weighted_routing_policy {
    weight = "${var.weighted_routing_policy}"
  }

  set_identifier = "${var.identifier}"

  alias {
    name                   = "${aws_elb.elb.dns_name}"
    zone_id                = "${aws_elb.elb.zone_id}"
    evaluate_target_health = true
  }
}

module "deploy_app" {
  source               = "../deploy"
  service_name         = "${var.service_name}"
  elb_name             = "${aws_elb.elb.name}"
  code_deploy_role_arn = "${var.code_deploy_role_arn}"
  asg                  = "${aws_autoscaling_group.asg.name}"
}

output "asg_sg_id" {
  value = "${module.asg_sg.id}"
}
