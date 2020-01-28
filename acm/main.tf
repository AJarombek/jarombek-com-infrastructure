/**
 * ACM certificates for the JarombekCom Application
 * Author: Andrew Jarombek
 * Date: 3/21/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

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

data "aws_route53_zone" "jarombek-com-zone" {
  name = "jarombek.com."
  private_zone = false
}

#--------------------------
# New AWS Resources for ACM
#--------------------------

#------------------------------
# Protects '*.demo.jarombek.com'
#------------------------------

module "jarombek-demo-acm-certificate" {
  source = "github.com/ajarombek/terraform-modules//acm-certificate?ref=v0.1.8"

  # Mandatory arguments
  name = "jarombek-demo-acm-certificate"
  tag_name = "jarombek-demo-acm-certificate"
  tag_application = "jarombek-com"
  tag_environment = "production"

  route53_zone_name = "jarombek.com."
  acm_domain_name = "*.demo.jarombek.com"

  # Optional arguments
  route53_zone_private = false
}

#------------------------------
# Protects '*.asset.jarombek.com'
#------------------------------

resource "aws_acm_certificate" "jarombek-asset-wildcard-acm-certificate" {
  domain_name = "*.asset.jarombek.com"
  validation_method = "DNS"

  tags = {
    Environment = "prod"
    Application = "jarombek-com"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "jarombek-asset-wc-cert-validation-record" {
  name = aws_acm_certificate.jarombek-asset-wildcard-acm-certificate.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.jarombek-asset-wildcard-acm-certificate.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.jarombek-com-zone.id
  records = [
    aws_acm_certificate.jarombek-asset-wildcard-acm-certificate.domain_validation_options[0].resource_record_value
  ]
  ttl = 60
}

resource "aws_acm_certificate_validation" "jarombek-asset-wc-cert-validation" {
  certificate_arn = aws_acm_certificate.jarombek-asset-wildcard-acm-certificate.arn
  validation_record_fqdns = [aws_route53_record.jarombek-asset-wc-cert-validation-record.fqdn]
}

#------------------------------
# Protects '*.dev.jarombek.com'
#------------------------------

resource "aws_acm_certificate" "jarombek-dev-wildcard-acm-certificate" {
  domain_name = "*.dev.jarombek.com"
  validation_method = "DNS"

  tags = {
    Environment = "dev"
    Application = "jarombek-com"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "jarombek-dev-wc-cert-validation-record" {
  name = aws_acm_certificate.jarombek-dev-wildcard-acm-certificate.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.jarombek-dev-wildcard-acm-certificate.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.jarombek-com-zone.id
  records = [
    aws_acm_certificate.jarombek-dev-wildcard-acm-certificate.domain_validation_options[0].resource_record_value
  ]
  ttl = 60
}

resource "aws_acm_certificate_validation" "jarombek-dev-wc-cert-validation" {
  certificate_arn = aws_acm_certificate.jarombek-dev-wildcard-acm-certificate.arn
  validation_record_fqdns = [aws_route53_record.jarombek-dev-wc-cert-validation-record.fqdn]
}

#--------------------------
# Protects '*.jarombek.com'
#--------------------------

resource "aws_acm_certificate" "jarombek-wildcard-acm-certificate" {
  domain_name = "*.jarombek.com"
  validation_method = "DNS"

  tags = {
    Environment = "all"
    Application = "jarombek-com"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "jarombek-wc-cert-validation" {
  certificate_arn = aws_acm_certificate.jarombek-wildcard-acm-certificate.arn
  validation_record_fqdns = [aws_route53_record.jarombek-cert-validation-record.fqdn]
}

#------------------------
# Protects 'jarombek.com'
#------------------------

resource "aws_acm_certificate" "jarombek-acm-certificate" {
  domain_name = "jarombek.com"
  validation_method = "DNS"

  tags = {
    Environment = "prod"
    Application = "jarombek-com"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "jarombek-cert-validation-record" {
  name = aws_acm_certificate.jarombek-acm-certificate.domain_validation_options[0].resource_record_name
  type = aws_acm_certificate.jarombek-acm-certificate.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.jarombek-com-zone.id
  records = [aws_acm_certificate.jarombek-acm-certificate.domain_validation_options[0].resource_record_value]
  ttl = 60
}

resource "aws_acm_certificate_validation" "jarombek-cert-validation" {
  certificate_arn = aws_acm_certificate.jarombek-acm-certificate.arn
  validation_record_fqdns = [aws_route53_record.jarombek-cert-validation-record.fqdn]
}