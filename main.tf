/**
 * Author: Andrew Jarombek
 * Date: 9/7/2018
 */

provider "aws" {
  region = "us-east-1"
}

module "s3-tfstate" {
  source = "s3-tfstate"
}

module "vpc" {
  source = "vpc"
}

module "ami" {
  source = "ami"
}

module "ec2-web" {
  source = "ec2-web"
  security_group_id = "${module.vpc.public-subnet-security-group-id}"
  ami = "${module.ami.ami}"
}

module "ec2-mongodb" {
  source = "ec2-mongodb"
}

module "s3-assets" {
  source = "s3-assets"
}

module "route53" {
  source = "route53"

  ip = "18.188.35.236"
}