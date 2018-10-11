provider "aws" {
  alias   = "ireland"
  version = "1.40.0"
  region  = "eu-west-1"
}

provider "aws" {
  alias   = "frankfurt"
  version = "1.40.0"
  region  = "eu-central-1"
}

provider "template" {
  version = "1.0.0"
}

provider "null" {
  version = "1.0.0"
}
