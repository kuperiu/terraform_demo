resource "aws_security_group" "basic_sg" {
  name = "${var.service_name}"

  vpc_id = "${var.vpc_id}"

  tags = "${merge(var.tags, map("Name", format("%s", var.service_name)))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.basic_sg.id}"
  depends_on        = ["aws_security_group.basic_sg"]
}

resource "aws_security_group_rule" "basic_sg_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.basic_sg.id}"
  depends_on        = ["aws_security_group.basic_sg"]
}

resource "aws_security_group_rule" "basic_sg_rule" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.basic_sg.id}"
  depends_on        = ["aws_security_group.basic_sg"]
}

resource "aws_security_group_rule" "basic_sg_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.basic_sg.id}"
  depends_on        = ["aws_security_group.basic_sg"]
}
#####################
####################

resource "aws_elb" "elb" {
  name               = "${var.service_name}"
  security_groups    = ["${aws_security_group.basic_sg.id}"]
  availability_zones = "${var.availability_zones}"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:8080/hello"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "tcp"
    instance_port     = 8080
    instance_protocol = "tcp"
  }

  tags       = "${var.tags}"
  depends_on = ["aws_security_group.basic_sg"]
}

######
resource "aws_iam_policy" "asg_iam_policy" {
  name   = "${var.service_name}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.service_policy.json}"
}

resource "aws_iam_role" "asg_iam_role" {
  name = "${var.service_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "asg_iam_role_policy_attachment" {
  role       = "${var.service_name}"
  policy_arn = "${aws_iam_policy.asg_iam_policy.arn}"
}

resource "aws_iam_instance_profile" "asg_iam_profile" {
  name = "${var.service_name}"
  role = "${aws_iam_role.asg_iam_role.name}"
}

data "template_file" "user_data" {
  template = "${file("userdata.tpl")}"
}

resource "aws_launch_configuration" "iam_launch_config" {
  name_prefix                 = "${var.service_name}"
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.basic_sg.id}"]            ##ass sec group
  associate_public_ip_address = "false"
  iam_instance_profile        = "${aws_iam_instance_profile.asg_iam_profile.id}"
  user_data                   = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_security_group.basic_sg"]
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
  availability_zones   = "${var.availability_zones}"
  max_size             = 0
  min_size             = 0
  desired_capacity     = 0
  load_balancers       = ["${aws_elb.elb.name}"]

  tags = ["${concat(
      list(map("key", "Name", "value", var.service_name, "propagate_at_launch", true)),
      local.tags_asg_format
      )}"]

  lifecycle {
    create_before_destroy = true
  }
}
