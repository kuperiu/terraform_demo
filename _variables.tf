variable "service_name" {
  default = "opssolution"
}

variable "ireland_ami" {
  default = "ami-00035f41c82244dab"
}

variable "frankfurt_ami" {
  default = "ami-0bdf93799014acdc4"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "bootstrap"
}

variable "tags" {
  default = {
    "Applcation"       = "CHRONOS_FE"
    "OTAP Environment" = "D"
  }
}

variable "ireland_vpc_id" {
  default = "vpc-0a9fe809567fd6dca"
}

variable "frankfurt_vpc_id" {
  default = "vpc-5aa70332"
}

variable "availability_zones" {
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  type    = "list"
}

variable "ports" {
  default = ["80", "8080", "22"]
}

variable "elb_health_check" {
  default = "HTTP:8080/hello"
}

variable "aws_availability_zones" {
  default = {
    //  N. Virginia
    us-east-1 = [
      "eu-east-1a",
      "eu-east-1b",
      "eu-east-1c",
      "eu-east-1d",
      "eu-east-1e",
      "eu-east-1f",
    ]

    //  Ohio
    us-east-2 = [
      "eu-east-2a",
      "eu-east-2b",
      "eu-east-2c",
    ]

    //  N. California
    us-west-1 = [
      "us-west-1a",
      "us-west-1b",
      "us-west-1c",
    ]

    //  Oregon
    us-west-2 = [
      "us-west-2a",
      "us-west-2b",
      "us-west-2c",
    ]

    //  Mumbai
    ap-south-1 = [
      "ap-south-1a",
      "ap-south-1b",
    ]

    //  Seoul
    ap-northeast-2 = [
      "ap-northeast-2a",
      "ap-northeast-2b",
    ]

    //  Singapore
    ap-southeast-1 = [
      "ap-southeast-1a",
      "ap-southeast-1b",
      "ap-southeast-1c",
    ]

    //  Sydney
    ap-southeast-2 = [
      "ap-southeast-2a",
      "ap-southeast-2b",
      "ap-southeast-2c",
    ]

    //  Tokyo (4)
    ap-northeast-1 = [
      "ap-northeast-1a",
      "ap-northeast-1b",
      "ap-northeast-1c",
    ]

    //  Osaka-Local (1)
    //  Central
    ca-central-1 = [
      "ca-central-1a",
      "ca-central-1b",
    ]

    //  Beijing (2)
    //  Ningxia (2)

    //  Frankfurt (3)
    eu-central-1 = [
      "eu-central-1a",
      "eu-central-1b",
      "eu-central-1c",
    ]
    //  Ireland (3)
    eu-west-1 = [
      "eu-west-1a",
      "eu-west-1b",
      "eu-west-1c",
    ]
    //  London (3)
    eu-west-2 = [
      "eu-west-2a",
      "eu-west-2b",
      "eu-west-2c",
    ]
    //  Paris (3)
    eu-west-3 = [
      "eu-west-3a",
      "eu-west-3b",
      "eu-west-3c",
    ]
    //  São Paulo (3)
    sa-east-1 = [
      "sa-east-1a",
      "sa-east-1b",
      "sa-east-1c",
    ]

    //  AWS GovCloud (US-West) (2)
  }
}
