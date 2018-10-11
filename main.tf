resource "aws_route53_zone" "main" {
  name     = "${var.service_name}"
  tags     = "${var.tags}"
  vpc_id   = "${var.ireland_vpc_id}"
  provider = "aws.ireland"
}

# ##we only create iam once because it's cross region
module "basic_iam" {
  source       = "modules/iam"
  service_name = "${var.service_name}"

  providers = {
    aws = "aws.ireland"
  }
}

module "baisc_asg_ireland" {
  source                  = "modules/asg"
  service_name            = "${var.service_name}"
  ami                     = "${var.ireland_ami}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.key_name}"
  iam_instance_profile    = "${module.basic_iam.basic_iam_id}"
  tags                    = "${var.tags}"
  availability_zones      = "${var.aws_availability_zones["eu-west-1"]}"
  desierd_instances       = 2
  ports                   = "${var.ports}"
  elb_health_check        = "${var.elb_health_check}"
  vpc_id                  = "${var.ireland_vpc_id}"
  zone_id                 = "${aws_route53_zone.main.zone_id}"
  identifier              = "ireland"
  weighted_routing_policy = 50

  providers = {
    aws = "aws.ireland"
  }
}

module "baisc_asg_frankfurt" {
  source                  = "modules/asg"
  service_name            = "${var.service_name}"
  ami                     = "${var.frankfurt_ami}"
  instance_type           = "${var.instance_type}"
  key_name                = "${var.key_name}"
  iam_instance_profile    = "${module.basic_iam.basic_iam_id}"
  tags                    = "${var.tags}"
  availability_zones      = "${var.aws_availability_zones["eu-central-1"]}"
  desierd_instances       = 2
  ports                   = "${var.ports}"
  elb_health_check        = "${var.elb_health_check}"
  vpc_id                  = "${var.frankfurt_vpc_id}"
  zone_id                 = "${aws_route53_zone.main.zone_id}"
  identifier              = "frankfurt"
  weighted_routing_policy = 50

  providers = {
    aws = "aws.frankfurt"
  }
}
