variable "service_name" {}
variable "vpc_id" {}

variable "tags" {
  type = "map"
}

variable "port" {}

variable "cidr_blocks" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

variable "source_security_group_id" {
  default = 1234
}

variable "associated" {}

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

resource "aws_security_group_rule" "basic_sg_rule_with_cidr" {
  count             = "${var.associated ? 0 : 1}"
  type              = "ingress"
  from_port         = "${var.port}"
  to_port           = "${var.port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.basic_sg.id}"
  cidr_blocks       = "${var.cidr_blocks}"
  depends_on        = ["aws_security_group.basic_sg"]
}

resource "aws_security_group_rule" "basic_sg_rule_associated" {
  count                    = "${var.associated ? 1 : 0}"
  type                     = "ingress"
  from_port                = "${var.port}"
  to_port                  = "${var.port}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.basic_sg.id}"
  source_security_group_id = "${var.source_security_group_id}"
  depends_on               = ["aws_security_group.basic_sg"]
}

output "id" {
  value = "${aws_security_group.basic_sg.id}"
}

output "name" {
  value = "${aws_security_group.basic_sg.name}"
}
