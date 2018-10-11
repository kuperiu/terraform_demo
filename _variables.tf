variable "service_name" {
  default = "testing123"
}

variable "ami" {
  default = "ami-00035f41c82244dab"
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

variable "vpc_id" {
  default = "vpc-0a9fe809567fd6dca"
}

variable "availability_zones" {
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  type    = "list"
}
