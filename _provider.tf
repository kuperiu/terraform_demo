provider "aws" {
  region  = "eu-west-1"
  version = "1.40.0"
}

provider "template" {
  version = "1.0.0"
}

provider "null" {
  version = "1.0.0"
}
