/**
 * ACM certificates for the JarombekCom Application
 * Author: Andrew Jarombek
 * Date: 3/21/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.6.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "jarombek-com-infrastructure/acm"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "jarombek-com-infrastructure/acm"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_route53_zone" "jarombek-com-zone" {
  name         = "jarombek.com."
  private_zone = false
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

#--------------------------
# Protects '*.jarombek.com'
#--------------------------

resource "aws_acm_certificate" "jarombek-wildcard-acm-certificate" {
  domain_name       = "*.jarombek.com"
  validation_method = "DNS"

  tags = {
    Name        = "jarombek-com-wildcard-acm-certificate"
    Application = "jarombek-com"
    Environment = "production"
    Terraform   = local.terraform_tag
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "jarombek-wc-cert-validation" {
  certificate_arn         = aws_acm_certificate.jarombek-wildcard-acm-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.jarombek-cert-validation-record : record.fqdn]
}

#------------------------
# Protects 'jarombek.com'
#------------------------

resource "aws_acm_certificate" "jarombek-acm-certificate" {
  domain_name       = "jarombek.com"
  validation_method = "DNS"

  tags = {
    Name        = "jarombek-com-acm-certificate"
    Application = "jarombek-com"
    Environment = "production"
    Terraform   = local.terraform_tag
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "jarombek-cert-validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.jarombek-acm-certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = data.aws_route53_zone.jarombek-com-zone.id
  records         = [each.value.record]
  ttl             = 60
}

resource "aws_acm_certificate_validation" "jarombek-cert-validation" {
  certificate_arn         = aws_acm_certificate.jarombek-acm-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.jarombek-cert-validation-record : record.fqdn]
}