/**
 * ACM certificates for the JarombekCom Application
 * Author: Andrew Jarombek
 * Date: 3/21/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/acm"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_route53_zone" "saints-xctf-zone" {
  name = "jarombek.io."
  private_zone = false
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

#--------------------------
# Protects '*.jarombek.com'
#--------------------------

resource "aws_acm_certificate" "jarombek-wildcard-acm-certificate" {
  domain_name = "*.jarombek.io"
  validation_method = "DNS"

  tags {
    Environment = "all"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "jarombek-wc-cert-validation-record" {
  name = "${aws_acm_certificate.jarombek-wildcard-acm-certificate.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.jarombek-wildcard-acm-certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.saints-xctf-zone.id}"
  records = ["${aws_acm_certificate.jarombek-wildcard-acm-certificate.domain_validation_options.0.resource_record_value}"]
  ttl = 60
}

resource "aws_acm_certificate_validation" "jarombek-wc-cert-validation" {
  certificate_arn = "${aws_acm_certificate.jarombek-wildcard-acm-certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.jarombek-wc-cert-validation-record.fqdn}"]
}

#------------------------
# Protects 'jarombek.com'
#------------------------

resource "aws_acm_certificate" "jarombek-acm-certificate" {
  domain_name = "jarombek.io"
  validation_method = "DNS"

  tags {
    Environment = "prod"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "jarombek-cert-validation-record" {
  name = "${aws_acm_certificate.jarombek-acm-certificate.domain_validation_options.0.resource_record_name}"
  type = "${aws_acm_certificate.jarombek-acm-certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.saints-xctf-zone.id}"
  records = ["${aws_acm_certificate.jarombek-acm-certificate.domain_validation_options.0.resource_record_value}"]
  ttl = 60
}

resource "aws_acm_certificate_validation" "jarombek-cert-validation" {
  certificate_arn = "${aws_acm_certificate.jarombek-acm-certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.jarombek-cert-validation-record.fqdn}"]
}