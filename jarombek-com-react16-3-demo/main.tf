/**
 * Static website for the React 16.3 demo application discussed in a software development article.  The S3 bucket has
 * the domain react16-3.demo.jarombek.com
 * Author: Andrew Jarombek
 * Date: 1/27/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.1.2"

  required_providers {
    aws = ">= 3.70.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "jarombek-com-infrastructure/jarombek-com-demo"
    region  = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_acm_certificate" "wildcard-react16-3-demo-jarombek-com-cert" {
  domain = "*.react16-3.demo.jarombek.com"
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

resource "aws_s3_bucket" "react16-3-demo-jarombek" {
  bucket = "react16-3.demo.jarombek.com"
  acl    = "private"

  tags = {
    Name        = "react16-3.demo.jarombek.com"
    Environment = "production"
    Application = "react-16-3-demo"
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "react16-3-demo-jarombek" {
  bucket = aws_s3_bucket.react16-3-demo-jarombek.id
  policy = data.aws_iam_policy_document.react16-3-demo-jarombek.json
}

data "aws_iam_policy_document" "react16-3-demo-jarombek" {
  statement {
    sid = "CloudfrontOAI"

    principals {
      identifiers = [aws_cloudfront_origin_access_identity.origin-access-identity.iam_arn]
      type        = "AWS"
    }

    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.react16-3-demo-jarombek.arn,
      "${aws_s3_bucket.react16-3-demo-jarombek.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "react16-3-demo-jarombek" {
  bucket = aws_s3_bucket.react16-3-demo-jarombek.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_cloudfront_distribution" "react16-3-demo-jarombek-distribution" {
  origin {
    domain_name = aws_s3_bucket.react16-3-demo-jarombek.bucket_regional_domain_name
    origin_id   = "origin-bucket-${aws_s3_bucket.react16-3-demo-jarombek.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept user requests
  enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment             = "react16-3.demo.jarombek.com CloudFront Distribution"
  default_root_object = "index.html"

  # Extra CNAMEs for this distribution
  aliases = ["react16-3.demo.jarombek.com"]

  # The pricing model for CloudFront
  price_class = "PriceClass_100"

  default_cache_behavior {
    # Which HTTP verbs CloudFront processes
    allowed_methods = ["HEAD", "GET"]

    # Which HTTP verbs CloudFront caches responses to requests
    cached_methods = ["HEAD", "GET"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }

    target_origin_id = "origin-bucket-${aws_s3_bucket.react16-3-demo-jarombek.id}"

    # Which protocols to use when accessing items from CloudFront
    viewer_protocol_policy = "redirect-to-https"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 30
    response_code         = 200
    response_page_path    = "/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.wildcard-demo-jarombek-com-cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Name        = "react16-3-demo-jarombek-com-cloudfront"
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "react16-3.demo.jarombek.com origin access identity"
}

resource "aws_cloudfront_distribution" "www-react16-3-demo-jarombek-distribution" {
  origin {
    domain_name = aws_s3_bucket.react16-3-demo-jarombek.bucket_regional_domain_name
    origin_id   = "origin-bucket-${aws_s3_bucket.react16-3-demo-jarombek.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept user requests
  enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment             = "www.react16-3.demo.jarombek.com CloudFront Distribution"
  default_root_object = "index.html"

  # Extra CNAMEs for this distribution
  aliases = ["www.react16-3.demo.jarombek.com"]

  # The pricing model for CloudFront
  price_class = "PriceClass_100"

  default_cache_behavior {
    # Which HTTP verbs CloudFront processes
    allowed_methods = ["HEAD", "GET"]

    # Which HTTP verbs CloudFront caches responses to requests
    cached_methods = ["HEAD", "GET"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }

    target_origin_id = "origin-bucket-${aws_s3_bucket.react16-3-demo-jarombek.id}"

    # Which protocols to use when accessing items from CloudFront
    viewer_protocol_policy = "allow-all"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 30
    response_code         = 200
    response_page_path    = "/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.wildcard-react16-3-demo-jarombek-com-cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Name        = "www-react16-3-demo-jarombek-com-cloudfront"
    Environment = "production"
  }
}

resource "aws_route53_record" "demo-jarombek-a" {
  name    = "react16-3.demo.jarombek.com."
  type    = "A"
  zone_id = data.aws_route53_zone.jarombek.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.react16-3-demo-jarombek-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.react16-3-demo-jarombek-distribution.hosted_zone_id
  }
}

resource "aws_route53_record" "www-demo-jarombek-a" {
  name    = "www.react16-3.demo.jarombek.com."
  type    = "A"
  zone_id = data.aws_route53_zone.jarombek.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.www-react16-3-demo-jarombek-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www-react16-3-demo-jarombek-distribution.hosted_zone_id
  }
}

#-------------------
# S3 Bucket Contents
#-------------------

resource "aws_s3_bucket_object" "app-js" {
  bucket       = aws_s3_bucket.react16-3-demo-jarombek.id
  key          = "app.js"
  source       = "assets/app.js"
  etag         = filemd5("${path.cwd}/assets/app.js")
  content_type = "application/javascript"
}

resource "aws_s3_bucket_object" "index-html" {
  bucket       = aws_s3_bucket.react16-3-demo-jarombek.id
  key          = "index.html"
  source       = "assets/index.html"
  etag         = filemd5("${path.cwd}/assets/index.html")
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "styles-css" {
  bucket       = aws_s3_bucket.react16-3-demo-jarombek.id
  key          = "styles.css"
  source       = "assets/styles.css"
  etag         = filemd5("${path.cwd}/assets/styles.css")
  content_type = "text/css"
}

resource "aws_s3_bucket_object" "styles-js" {
  bucket       = aws_s3_bucket.react16-3-demo-jarombek.id
  key          = "styles.js"
  source       = "assets/styles.js"
  etag         = filemd5("${path.cwd}/assets/styles.js")
  content_type = "application/javascript"
}