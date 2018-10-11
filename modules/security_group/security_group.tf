variable "service_name" {}
variable "vpc_id" {}

variable "tags" {
  type = "map"
}

variable "ports" {
  type = "list"
}

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
  count             = "${length(var.ports)}"
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.basic_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  depends_on        = ["aws_security_group.basic_sg"]
}

output "basic_sg_id" {
  value = "${aws_security_group.basic_sg.id}"
}
