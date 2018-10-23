variable "service_name" {
  default = "opssolution"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "tags" {
  default = {
    "Applcation"       = "microservices"
    "Environment" = "dev"
  }
}