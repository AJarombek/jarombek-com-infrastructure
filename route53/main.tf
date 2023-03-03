/*
 * DNS and Domain Name Registration for all environments
 * Author: Andrew Jarombek
 * Date: 4/8/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 3.36.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "jarombek-com-infrastructure/route53"
    region  = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_s3_bucket" "asset-jarombek-bucket" {
  bucket = "asset.jarombek.com"
}

data "aws_s3_bucket" "www-asset-jarombek-bucket" {
  bucket = "www.asset.jarombek.com"
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

resource "aws_route53_zone" "jarombek" {
  name = "jarombek.com."
}

resource "aws_route53_record" "jarombek_mx" {
  name    = "jarombek.com."
  type    = "MX"
  zone_id = aws_route53_zone.jarombek.zone_id
  ttl     = 300

  records = [
    "1 ASPMX.L.GOOGLE.COM.",
    "5 ALT1.ASPMX.L.GOOGLE.COM.",
    "5 ALT2.ASPMX.L.GOOGLE.COM.",
    "10 ALT3.ASPMX.L.GOOGLE.COM.",
    "10 ALT4.ASPMX.L.GOOGLE.COM."
  ]
}