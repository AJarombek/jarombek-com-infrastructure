/*
 * DNS and Domain Name Registration for the jarombek.com application
 * Author: Andrew Jarombek
 * Date: 4/8/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/route53/env/prod"
    region = "us-east-1"
  }
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

module "dns" {
  source = "../../modules/dns"
  prod = true
}