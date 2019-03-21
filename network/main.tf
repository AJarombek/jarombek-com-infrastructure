/**
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/jarombek-com-fn"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_elb" "jarombek-com-elb" {
  name = "jarombek-com-elb"
}

#------------------
# Terraform Modules
#------------------

module "route53" {
  source = "./route53"

  ip = "${data.aws_elb.jarombek-com-elb.dns_name}"
}