/**
 * Author: Andrew Jarombek
 * Date: 9/7/2018
 */

provider "aws" {
  alias = "aws-us-east"
  region = "us-east-1"
}

provider "mongodbatlas" {
  alias = "mongo"
  username = "${var.mongodb_atlas_username}"
  api_key = "${var.mongodb_atlas_api_key}"

  # Matches any non-beta version >= 0.6.0 and < 0.7.0
  # Specifying a version is reommended for third-party providers
  version = "~> 0.6"
}

module "s3-tfstate" {
  source = "services\/s3-tfstate"
  providers = {
    aws = "aws.aws-us-east"
  }
}

module "vpc" {
  source = "network\/vpc"
  providers = {
    aws = "aws.aws-us-east"
  }
}

module "ami" {
  source = "services\/ami"
  providers = {
    aws = "aws.aws-us-east"
  }
}

module "ec2-web" {
  source = "services\/ec2-web"

  security_group_id = "${module.vpc.public-subnet-security-group-id}"
  ami = "${module.ami.ami}"
  subnet_id = "${module.vpc.public-subnet-id}"

  providers = {
    aws = "aws.aws-us-east"
  }
}

module "ec2-mongodb" {
  source = "data-storage\/mongodb"

  security_group_id = "${module.vpc.private-subnet-security-group-id}"
  ami = "${module.ami.ami}"
  subnet_id = "${module.vpc.private-subnet-id}"

  providers = {
    aws = "mongodbatlas.mongo"
  }
}

module "s3-assets" {
  source = "services\/s3-assets"
  providers = {
    aws = "aws.aws-us-east"
  }
}

module "route53" {
  source = "network\/route53"

  ip = "18.188.35.236"

  providers = {
    aws = "aws.aws-us-east"
  }
}