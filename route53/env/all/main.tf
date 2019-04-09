/*
 * DNS and Domain Name Registration for all environments
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
    key = "jarombek-com-infrastructure/route53/env/all"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_s3_bucket" "asset-jarombek-bucket" {
  bucket = "asset-jarombek"
}

data "aws_s3_bucket" "www-asset-jarombek-bucket" {
  bucket = "www-asset-jarombek"
}

#------------------------------
# New AWS Resources for Route53
#------------------------------

resource "aws_route53_zone" "jarombek" {
  name = "jarombek.com."
}

resource "aws_route53_record" "jarombek_ns" {
  name = "jarombek.com."
  type = "NS"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"
  ttl = 172800

  records = [
    "${aws_route53_zone.jarombek.name_servers.0}",
    "${aws_route53_zone.jarombek.name_servers.1}",
    "${aws_route53_zone.jarombek.name_servers.2}",
    "${aws_route53_zone.jarombek.name_servers.3}"
  ]
}

resource "aws_route53_record" "asset_jarombek_a" {
  name = "assets.jarombek.com."
  type = "A"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"

  # TTL for all alias records is 60 seconds
  alias {
    evaluate_target_health = false
    name = "${data.aws_s3_bucket.asset-jarombek-bucket.website_domain}"
    zone_id = "${data.aws_s3_bucket.asset-jarombek-bucket.hosted_zone_id}"
  }
}

resource "aws_route53_record" "www_asset_jarombek_a" {
  name = "www.assets.jarombek.com."
  type = "A"
  zone_id = "${aws_route53_zone.jarombek.zone_id}"

  # TTL for all alias records is 60 seconds
  alias {
    evaluate_target_health = false
    name = "${data.aws_s3_bucket.www-asset-jarombek-bucket.website_domain}"
    zone_id = "${data.aws_s3_bucket.www-asset-jarombek-bucket.hosted_zone_id}"
  }
}