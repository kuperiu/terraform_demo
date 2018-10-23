variable "vpc_id" {}
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

variable "elb_port" {}
variable "asg_port" {}
variable "elb_health_check" {}
variable "identifier" {}
variable "weighted_routing_policy" {}
variable "code_deploy_role_arn" {}

variable "internal_elb" {
  default = false
}

variable "cidr_blocks" {
  type = "list"
  default = ["0.0.0.0/0"]
}

variable "associated" {}

variable "public_subnets" {
  type = "list"
}

variable "private_subnets" {
  type = "list"
}

variable "source_security_group_id" {
  default = 1234
}
