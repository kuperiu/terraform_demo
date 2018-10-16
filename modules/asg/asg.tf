variable "service_name" {}
variable "ami" {}
variable "instance_type" {}
variable "zone_id" {}
variable "key_name" {}
variable "iam_instance_profile" {}

variable "tags" {
  type = "map"
}

variable "desierd_instances" {}

variable "ports" {
  type = "list"
}

variable "elb_health_check" {}
variable "vpc_id" {}
variable "identifier" {}
variable "weighted_routing_policy" {}

data "template_file" "user_data" {
  template = "${file("userdata.tpl")}"
}

data "aws_availability_zones" "available" {}

module "basic_sg" {
  source       = "../security_group"
  service_name = "${var.service_name}"
  vpc_id       = "${var.vpc_id}"
  tags         = "${var.tags}"
  ports        = "${var.ports}"
}

resource "aws_elb" "elb" {
  name               = "${var.service_name}"
  security_groups    = ["${module.basic_sg.basic_sg_id}"]
  availability_zones = ["${data.aws_availability_zones.available.names}"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "${var.elb_health_check}"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "tcp"
    instance_port     = 8080
    instance_protocol = "tcp"
  }

  tags = "${var.tags}"
}

resource "aws_launch_configuration" "iam_launch_config" {
  name_prefix                 = "${var.service_name}"
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${module.basic_sg.basic_sg_id}"]
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
  availability_zones   = ["${data.aws_availability_zones.available.names}"]
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
  name    = "apime.${var.service_name}"

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

# module "deploy_app" {
#   source       = "../deploy"
#   service_name = "${var.service_name}"
#   elb_name     = "${aws_elb.elb.name}"
#   asg = "${aws_autoscaling_group.asg.name}"
# }
