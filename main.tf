#
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "i-love-automation"

    workspaces {
      name = "api"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
