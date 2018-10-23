variable "service_name" {}

variable "tags" {
  type = "map"
}

data "aws_availability_zones" "available" {}

module "basic_vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "1.46.0"
  name               = "${var.service_name}"
  cidr               = "10.10.0.0/16"
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  private_subnets    = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets     = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = "${var.tags}"
}

resource "aws_key_pair" "basic_key" {
  key_name   = "deployer-key"
  public_key = "${file("/Users/lkuperiu/.ssh/id_rsa.pub")}"
}

output "private_subnets" {
  value = "${module.basic_vpc.private_subnets}"
}

output "public_subnets" {
  value = "${module.basic_vpc.public_subnets}"
}

output "key_name" {
  value = "${aws_key_pair.basic_key.key_name}"
}
