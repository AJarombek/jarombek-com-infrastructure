/*
 * DNS and Domain Name Registration for the dev.jarombek.com application
 * Author: Andrew Jarombek
 * Date: 4/8/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/route53/env/dev"
    region = "us-east-1"
  }
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

module "dns" {
  source = "../../modules/dns"
  prod = false
}