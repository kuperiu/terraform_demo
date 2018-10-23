variable "service_name" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "iam_instance_profile" {}
variable "code_deploy_role_arn" {}
variable "tags" {}
variable "desierd_instances" {}
variable "ports" {}
variable "elb_health_check" {}
variable "vpc_id" {}
variable "zone_id" {}

variable "identifier" {}
variable "weighted_routing_policy" {}

module "microservice_A" {
  source                  = "../modules/asg"
  service_name            = "${var.service_name}"
  ami                     = "${var.ami}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.key_name}"
  iam_instance_profile    = "${module.basic_iam.asg_iam_profile_id}"
  code_deploy_role_arn    = "${module.basic_iam.app_iam_role_arn}"
  tags                    = "${var.tags}"
  desierd_instances       = "${var.desierd_instances}"
  ports                   = "${var.ports}"
  elb_health_check        = "${var.elb_health_check}"
  vpc_id                  = "${var.frankfurt_vpc_id}"
  zone_id                 = "${var.zone_id}"
  identifier              = "${var.identifier}"
  weighted_routing_policy = "${var.weighted_routing_policy}"
}
