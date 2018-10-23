# # # ##we only create iam once because it's cross region
module "basic_iam" {
  source       = "modules/iam"
  service_name = "${var.service_name}"

  providers = {
    aws = "aws.frankfurt"
  }
}

# #####frankfurt
data "aws_availability_zones" "available" {
  provider = "aws.frankfurt"
}

module "basic_vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "1.46.0"
  name               = "microservices_network"
  cidr               = "10.10.0.0/16"
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets    = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets     = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_support	= true
  enable_dns_hostnames = true
  tags               = "${var.tags}"

  providers = {
    aws = "aws.frankfurt"
  }
}

resource "aws_route53_zone" "main" {
  name     = "${var.service_name}"
  tags     = "${var.tags}"
  vpc_id   = "${module.basic_vpc.vpc_id}"
  provider = "aws.frankfurt"
}

resource "aws_key_pair" "basic_key" {
  key_name   = "deployer-key"
  public_key = "${file("/Users/lkuperiu/.ssh/id_rsa.pub")}"
  provider   = "aws.frankfurt"
}

module "microservice_A" {
  source                  = "modules/asg"
  service_name            = "microservice-A"
  ami                     = "${data.aws_ami.ubuntu.id}"
  instance_type           = "${var.instance_type}"
  key_name                = "${aws_key_pair.basic_key.key_name}"
  iam_instance_profile    = "${module.basic_iam.asg_iam_profile_id}"
  code_deploy_role_arn    = "${module.basic_iam.app_iam_role_arn}"
  public_subnets          = ["${module.basic_vpc.public_subnets}"]
  private_subnets         = ["${module.basic_vpc.private_subnets}"]
  tags                    = "${var.tags}"
  desierd_instances       = 2
  elb_port                = 80
  elb_health_check        = "HTTP:80/"
  asg_port                = 80
  vpc_id                  = "${module.basic_vpc.vpc_id}"
  zone_id                 = "${aws_route53_zone.main.zone_id}"
  identifier              = "frankfurt"
  weighted_routing_policy = 50
  cidr_blocks             = ["0.0.0.0/0"]
  associated              = true
  providers = {
    aws = "aws.frankfurt"
  }
}

module "microservice_B" {
  source                  = "modules/asg"
  service_name            = "microservice-B"
  ami                     = "${data.aws_ami.ubuntu.id}"
  instance_type           = "${var.instance_type}"
  key_name                = "${aws_key_pair.basic_key.key_name}"
  iam_instance_profile    = "${module.basic_iam.asg_iam_profile_id}"
  code_deploy_role_arn    = "${module.basic_iam.app_iam_role_arn}"
  public_subnets          = ["${module.basic_vpc.public_subnets}"]
  private_subnets         = ["${module.basic_vpc.private_subnets}"]
  tags                    = "${var.tags}"
  desierd_instances       = 2
  elb_port                = 80
  elb_health_check        = "HTTP:80/"
  asg_port                = 80
  vpc_id                  = "${module.basic_vpc.vpc_id}"
  zone_id                 = "${aws_route53_zone.main.zone_id}"
  identifier              = "frankfurt"
  weighted_routing_policy = 50
  source_security_group_id = "${module.microservice_A.asg_sg_id}"
  associated              = true
  internal_elb            = true
  providers = {
    aws = "aws.frankfurt"
  }
}

# ##############

