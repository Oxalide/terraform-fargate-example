terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "puppet-forge"

    workspaces {
      name = "forge-fargate"
    }
  }
}

provider "aws" {
  version    = "~> 2.0"
  region     = "us-west-2"
}
