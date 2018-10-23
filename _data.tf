terraform {
  required_version = ">= 0.11.8" # introduction of Local Values configuration language feature
}

data "template_file" "user_data" {
  template = "${file("userdata.tpl")}"
}

data "aws_ami" "ubuntu" {
  provider = "aws.frankfurt"
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}