/**
 * ACM certificates for the JarombekCom Application
 * Author: Andrew Jarombek
 * Date: 3/21/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = ">= 3.48.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "jarombek-com-infrastructure/acm"
    region  = "us-east-1"
  }
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

#------------------------------
# Protects '*.react16-3.demo.jarombek.com'
#------------------------------

module "jarombek-react16-3-demo-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.12"

  # Mandatory arguments
  name            = "jarombek-react16-3-demo-acm-certificate"
  tag_name        = "jarombek-react16-3-demo-acm-certificate"
  tag_application = "jarombek-com"
  tag_environment = "production"

  route53_zone_name = "jarombek.com."
  acm_domain_name   = "*.react16-3.demo.jarombek.com"

  # Optional arguments
  route53_zone_private = false
}

#------------------------------
# Protects '*.demo.jarombek.com'
#------------------------------

module "jarombek-demo-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.12"

  # Mandatory arguments
  name            = "jarombek-demo-acm-certificate"
  tag_name        = "jarombek-demo-acm-certificate"
  tag_application = "jarombek-com"
  tag_environment = "production"

  route53_zone_name = "jarombek.com."
  acm_domain_name   = "*.demo.jarombek.com"

  # Optional arguments
  route53_zone_private = false
}

#-------------------------------------------------------------
# New ACM Resource that Protects '*.apollo.proto.jarombek.com'
#-------------------------------------------------------------

module "jarombek-apollo-proto-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.12"

  # Mandatory arguments
  name            = "jarombek-apollo-proto-acm-certificate"
  tag_name        = "jarombek-apollo-proto-acm-certificate"
  tag_application = "jarombek-com"
  tag_environment = "production"

  route53_zone_name = "jarombek.com."
  acm_domain_name   = "*.apollo.proto.jarombek.com"

  # Optional arguments
  route53_zone_private = false
}

#------------------------------
# Protects '*.proto.jarombek.com'
#------------------------------

module "jarombek-proto-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.12"

  # Mandatory arguments
  name            = "jarombek-proto-acm-certificate"
  tag_name        = "jarombek-proto-acm-certificate"
  tag_application = "jarombek-com"
  tag_environment = "production"

  route53_zone_name = "jarombek.com."
  acm_domain_name   = "*.proto.jarombek.com"

  # Optional arguments
  route53_zone_private = false
}

#------------------------------
# Protects '*.asset.jarombek.com'
#------------------------------

resource "aws_acm_certificate" "jarombek-asset-wildcard-acm-certificate" {
  domain_name       = "*.asset.jarombek.com"
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
  for_each = {
    for dvo in aws_acm_certificate.jarombek-asset-wildcard-acm-certificate.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "jarombek-asset-wc-cert-validation" {
  certificate_arn         = aws_acm_certificate.jarombek-asset-wildcard-acm-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.jarombek-asset-wc-cert-validation-record : record.fqdn]
}

#------------------------------
# Protects '*.dev.jarombek.com'
#------------------------------

module "jarombek-dev-acm-certificate" {
  source = "github.com/ajarombek/cloud-modules//terraform-modules/acm-certificate?ref=v0.2.12"

  # Mandatory arguments
  name            = "jarombek-dev-acm-certificate"
  tag_name        = "jarombek-dev-acm-certificate"
  tag_application = "jarombek-com"
  tag_environment = "development"

  route53_zone_name = "jarombek.com."
  acm_domain_name   = "*.dev.jarombek.com"

  # Optional arguments
  route53_zone_private = false
}

#--------------------------
# Protects '*.jarombek.com'
#--------------------------

resource "aws_acm_certificate" "jarombek-wildcard-acm-certificate" {
  domain_name       = "*.jarombek.com"
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
    Environment = "prod"
    Application = "jarombek-com"
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