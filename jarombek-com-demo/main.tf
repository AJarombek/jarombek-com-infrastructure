/**
 * Static website for demo applications discussed in software development articles.  The S3 bucket has the domain
 * demo.jarombek.com
 * Author: Andrew Jarombek
 * Date: 1/27/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/jarombek-com-demo"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_acm_certificate" "wildcard-jarombek-com-cert" {
  domain = "*.jarombek.com"
}

data "aws_acm_certificate" "wildcard-demo-jarombek-com-cert" {
  domain = "*.demo.jarombek.com"
}

data "aws_route53_zone" "jarombek" {
  name = "jarombek.com."
}

#--------------------------------------
# New AWS Resources for S3 & CloudFront
#--------------------------------------

resource "aws_s3_bucket" "demo-jarombek" {
  bucket = "demo.jarombek.com"
  acl = "public-read"
  policy = file("${path.module}/policy.json")

  tags = {
    Name = "demo.jarombek.com"
  }

  website {
    index_document = "jarombek.png"
    error_document = "jarombek.png"
  }

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
  }
}

resource "aws_s3_bucket" "www-demo-jarombek" {
  bucket = "www.demo.jarombek.com"
  acl = "public-read"
  policy = file("${path.module}/www-policy.json")

  tags = {
    Name = "www.demo.jarombek.com"
  }

  website {
    redirect_all_requests_to = "https://demo.jarombek.com"
  }
}

resource "aws_cloudfront_distribution" "demo-jarombek-distribution" {
  origin {
    domain_name = aws_s3_bucket.demo-jarombek.bucket_regional_domain_name
    origin_id = "origin-bucket-${aws_s3_bucket.demo-jarombek.id}"

    s3_origin_config {
      origin_access_identity =
        aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept user requests
  enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment = "demo.jarombek.com CloudFront Distribution"
  default_root_object = "jarombek.png"

  # Extra CNAMEs for this distribution
  aliases = ["demo.jarombek.com"]

  # The pricing model for CloudFront
  price_class = "PriceClass_100"

  default_cache_behavior {
    # Which HTTP verbs CloudFront processes
    allowed_methods = ["GET"]

    # Which HTTP verbs CloudFront caches responses to requests
    cached_methods = ["GET"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }

    target_origin_id = "origin-bucket-${aws_s3_bucket.demo-jarombek.id}"

    # Which protocols to use when accessing items from CloudFront
    viewer_protocol_policy = "redirect-to-https"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.wildcard-jarombek-com-cert.arn
    ssl_support_method = "sni-only"
  }

  tags = {
    Name = "demo-jarombek-com-cloudfront"
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "demo.jarombek.com origin access identity"
}

resource "aws_cloudfront_distribution" "www-demo-jarombek-distribution" {
  origin {
    domain_name = aws_s3_bucket.www-demo-jarombek.bucket_regional_domain_name
    origin_id = "origin-bucket-${aws_s3_bucket.www-demo-jarombek.id}"

    s3_origin_config {
      origin_access_identity =
        aws_cloudfront_origin_access_identity.origin-access-identity-www.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept user requests
  enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment = "www.demo.jarombek.com CloudFront Distribution"
  default_root_object = "jarombek.png"

  # Extra CNAMEs for this distribution
  aliases = ["www.demo.jarombek.com"]

  # The pricing model for CloudFront
  price_class = "PriceClass_100"

  default_cache_behavior {
    # Which HTTP verbs CloudFront processes
    allowed_methods = ["GET"]

    # Which HTTP verbs CloudFront caches responses to requests
    cached_methods = ["GET"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }

    target_origin_id = "origin-bucket-${aws_s3_bucket.www-demo-jarombek.id}"

    # Which protocols to use when accessing items from CloudFront
    viewer_protocol_policy = "allow-all"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.wildcard-demo-jarombek-com-cert.arn
    ssl_support_method = "sni-only"
  }

  tags = {
    Name = "www-demo-jarombek-com-cloudfront"
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity-www" {
  comment = "www.demo.jarombek.com origin access identity"
}

resource "aws_route53_record" "demo-jarombek-a" {
  name = "demo.jarombek.com."
  type = "A"
  zone_id = data.aws_route53_zone.jarombek.zone_id

  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.demo-jarombek-distribution.domain_name
    zone_id = aws_cloudfront_distribution.demo-jarombek-distribution.hosted_zone_id
  }
}

resource "aws_route53_record" "www-demo-jarombek-a" {
  name = "www.demo.jarombek.com."
  type = "A"
  zone_id = data.aws_route53_zone.jarombek.zone_id

  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.www-demo-jarombek-distribution.domain_name
    zone_id = aws_cloudfront_distribution.www-demo-jarombek-distribution.hosted_zone_id
  }
}

#-------------------
# S3 Bucket Contents
#-------------------
