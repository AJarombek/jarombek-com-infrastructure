/**
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

provider "aws" {
  region = "us-east-1"
}

data "aws_elb" "jarombek-com-elb" {
  name = "jarombek-com-elb"
}

module "vpc" {
  source = "./vpc"
}

module "route53" {
  source = "./route53"

  ip = "${data.aws_elb.jarombek-com-elb.dns_name}"
}

module "s3-tfstate" {
  source = "./s3-tfstate"
}