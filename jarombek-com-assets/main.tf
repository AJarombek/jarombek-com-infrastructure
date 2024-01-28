/**
 * Assets for the website located on an S3 bucket.  The S3 bucket has the domain asset.jarombek.com
 * Author: Andrew Jarombek
 * Date: 10/3/2018
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
    key     = "jarombek-com-infrastructure/jarombek-com-assets"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "jarombek-com-infrastructure/jarombek-com-assets"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_acm_certificate" "wildcard-jarombek-com-cert" {
  domain = "*.jarombek.com"
}

data "aws_route53_zone" "jarombek" {
  name = "jarombek.com."
}

#--------------------------------------
# New AWS Resources for S3 & CloudFront
#--------------------------------------

resource "aws_s3_bucket" "asset-jarombek" {
  bucket = "asset.jarombek.com"

  tags = {
    Name        = "asset.jarombek.com"
    Environment = "all"
    Application = "jarombek-com"
    Terraform   = local.terraform_tag
  }
}

resource "aws_s3_bucket_website_configuration" "asset-jarombek" {
  bucket = aws_s3_bucket.asset-jarombek.id

  index_document {
    suffix = "jarombek.png"
  }

  error_document {
    key = "jarombek.png"
  }
}

resource "aws_s3_bucket_cors_configuration" "asset-jarombek" {
  bucket = aws_s3_bucket.asset-jarombek.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
  }

  cors_rule {
    allowed_methods = ["POST", "PUT", "DELETE", "HEAD"]
    allowed_origins = ["https://jarombek.com"]
    allowed_headers = ["*"]
  }
}

resource "aws_s3_bucket_policy" "asset-jarombek" {
  bucket = aws_s3_bucket.asset-jarombek.id
  policy = data.aws_iam_policy_document.asset-jarombek.json
}

data "aws_iam_policy_document" "asset-jarombek" {
  statement {
    sid = "CloudfrontOAI"

    principals {
      identifiers = [aws_cloudfront_origin_access_identity.origin-access-identity.iam_arn]
      type        = "AWS"
    }

    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.asset-jarombek.arn,
      "${aws_s3_bucket.asset-jarombek.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "asset-jarombek" {
  bucket = aws_s3_bucket.asset-jarombek.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_cloudfront_distribution" "asset-jarombek-distribution" {
  origin {
    domain_name = aws_s3_bucket.asset-jarombek.bucket_regional_domain_name
    origin_id   = "origin-bucket-${aws_s3_bucket.asset-jarombek.id}"

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

  comment             = "asset.jarombek.com CloudFront Distribution"
  default_root_object = "jarombek.png"

  # Extra CNAMEs for this distribution
  aliases = ["asset.jarombek.com"]

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

    target_origin_id = "origin-bucket-${aws_s3_bucket.asset-jarombek.id}"

    # Which protocols to use when accessing items from CloudFront
    viewer_protocol_policy = "redirect-to-https"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.wildcard-jarombek-com-cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Name        = "asset-jarombek-com-cloudfront"
    Environment = "production"
    Application = "jarombek-com"
    Terraform   = local.terraform_tag
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "asset.jarombek.com origin access identity"
}

resource "aws_route53_record" "asset-jarombek-a" {
  name    = "asset.jarombek.com."
  type    = "A"
  zone_id = data.aws_route53_zone.jarombek.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.asset-jarombek-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.asset-jarombek-distribution.hosted_zone_id
  }
}

/*
 * S3 Bucket Contents
 */

/*
 * Root Directory
 */

resource "aws_s3_object" "jarombek-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "jarombek.png"
  source       = "asset/jarombek.png"
  etag         = filemd5("${path.cwd}/asset/jarombek.png")
  content_type = "image/png"
}

resource "aws_s3_object" "blizzard-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "blizzard.png"
  source       = "asset/blizzard.png"
  etag         = filemd5("${path.cwd}/asset/blizzard.png")
  content_type = "image/png"
}

resource "aws_s3_object" "bulk-insert-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "bulk-insert.png"
  source       = "asset/bulk-insert.png"
  etag         = filemd5("${path.cwd}/asset/bulk-insert.png")
  content_type = "image/png"
}

resource "aws_s3_object" "common-user-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "common-user.png"
  source       = "asset/common-user.png"
  etag         = filemd5("${path.cwd}/asset/common-user.png")
  content_type = "image/png"
}

resource "aws_s3_object" "computer-jpg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "computer.jpg"
  source       = "asset/computer.jpg"
  etag         = filemd5("${path.cwd}/asset/computer.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_object" "database-er-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "Database-ER.png"
  source       = "asset/Database-ER.png"
  etag         = filemd5("${path.cwd}/asset/Database-ER.png")
  content_type = "image/png"
}

resource "aws_s3_object" "diamond-uml-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "diamond-uml.png"
  source       = "asset/diamond-uml.png"
  etag         = filemd5("${path.cwd}/asset/diamond-uml.png")
  content_type = "image/png"
}

resource "aws_s3_object" "down-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "down.png"
  source       = "asset/down.png"
  etag         = filemd5("${path.cwd}/asset/down.png")
  content_type = "image/png"
}

resource "aws_s3_object" "down-black-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "down-black.png"
  source       = "asset/down-black.png"
  etag         = filemd5("${path.cwd}/asset/down-black.png")
  content_type = "image/png"
}

resource "aws_s3_object" "dynamic-jsx-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "dynamic-jsx.png"
  source       = "asset/dynamic-jsx.png"
  etag         = filemd5("${path.cwd}/asset/dynamic-jsx.png")
  content_type = "image/png"
}

resource "aws_s3_object" "error-message-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "error-message.png"
  source       = "asset/error-message.png"
  etag         = filemd5("${path.cwd}/asset/error-message.png")
  content_type = "image/png"
}

resource "aws_s3_object" "flag-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "flag.svg"
  source       = "asset/flag.svg"
  etag         = filemd5("${path.cwd}/asset/flag.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "home-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "home.png"
  source       = "asset/home.png"
  etag         = filemd5("${path.cwd}/asset/home.png")
  content_type = "image/png"
}

resource "aws_s3_object" "jarombek-home-background-jpg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "jarombek-home-background.jpg"
  source       = "asset/jarombek-home-background.jpg"
  etag         = filemd5("${path.cwd}/asset/jarombek-home-background.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_object" "mean-stack-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "MEAN-Stack.png"
  source       = "asset/MEAN-Stack.png"
  etag         = filemd5("${path.cwd}/asset/MEAN-Stack.png")
  content_type = "image/png"
}

resource "aws_s3_object" "kayak-jpg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "kayak.jpg"
  source       = "asset/kayak.jpg"
  etag         = filemd5("${path.cwd}/asset/kayak.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_object" "login-component-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "login-component.png"
  source       = "asset/login-component.png"
  etag         = filemd5("${path.cwd}/asset/login-component.png")
  content_type = "image/png"
}

resource "aws_s3_object" "main-component-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "main-component.png"
  source       = "asset/main-component.png"
  etag         = filemd5("${path.cwd}/asset/main-component.png")
  content_type = "image/png"
}

resource "aws_s3_object" "meowcat-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "meowcat.png"
  source       = "asset/meowcat.png"
  etag         = filemd5("${path.cwd}/asset/meowcat.png")
  content_type = "image/png"
}

resource "aws_s3_object" "search-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "search.png"
  source       = "asset/search.png"
  etag         = filemd5("${path.cwd}/asset/search.png")
  content_type = "image/png"
}

resource "aws_s3_object" "signup-component-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "signup-component.png"
  source       = "asset/signup-component.png"
  etag         = filemd5("${path.cwd}/asset/signup-component.png")
  content_type = "image/png"
}

resource "aws_s3_object" "triangles-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "triangles.png"
  source       = "asset/triangles.png"
  etag         = filemd5("${path.cwd}/asset/triangles.png")
  content_type = "image/png"
}

/*
 * Fonts Directory
 */

resource "aws_s3_object" "dyslexie-bold-ttf" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "fonts/dyslexie-bold.ttf"
  source       = "asset/fonts/dyslexie-bold.ttf"
  etag         = filemd5("${path.cwd}/asset/fonts/dyslexie-bold.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_object" "elegant-icons-eot" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "fonts/ElegantIcons.eot"
  source       = "asset/fonts/ElegantIcons.eot"
  etag         = filemd5("${path.cwd}/asset/fonts/ElegantIcons.eot")
  content_type = "font/otf"
}

resource "aws_s3_object" "elegant-icons-ttf" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "fonts/ElegantIcons.ttf"
  source       = "asset/fonts/ElegantIcons.ttf"
  etag         = filemd5("${path.cwd}/asset/fonts/ElegantIcons.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_object" "elegant-icons-woff" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "fonts/ElegantIcons.woff"
  source       = "asset/fonts/ElegantIcons.woff"
  etag         = filemd5("${path.cwd}/asset/fonts/ElegantIcons.woff")
  content_type = "font/woff"
}

resource "aws_s3_object" "fantasque-sans-mono-bold-ttf" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "fonts/FantasqueSansMono-Bold.ttf"
  source       = "asset/fonts/FantasqueSansMono-Bold.ttf"
  etag         = filemd5("${path.cwd}/asset/fonts/FantasqueSansMono-Bold.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_object" "longway-regular-otf" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "fonts/Longway-Regular.otf"
  source       = "asset/fonts/Longway-Regular.otf"
  etag         = filemd5("${path.cwd}/asset/fonts/Longway-Regular.otf")
  content_type = "font/otf"
}

resource "aws_s3_object" "sylexiad-sans-thin-ttf" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "fonts/SylexiadSansThin.ttf"
  source       = "asset/fonts/SylexiadSansThin.ttf"
  etag         = filemd5("${path.cwd}/asset/fonts/SylexiadSansThin.ttf")
  content_type = "font/ttf"
}

resource "aws_s3_object" "sylexiad-sans-thin-bold-ttf" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "fonts/SylexiadSansThin-Bold.ttf"
  source       = "asset/fonts/SylexiadSansThin-Bold.ttf"
  etag         = filemd5("${path.cwd}/asset/fonts/SylexiadSansThin-Bold.ttf")
  content_type = "font/ttf"
}

/*
 * Posts Directory
 */

resource "aws_s3_object" "posts-11-6-17-graph-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-6-17-FairfieldGraphImage.png"
  source       = "asset/posts/11-6-17-FairfieldGraphImage.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-6-17-FairfieldGraphImage.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-13-17-prompt-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-13-17-prompt.png"
  source       = "asset/posts/11-13-17-prompt.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-13-17-prompt.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-21-17-results-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-21-17-results.png"
  source       = "asset/posts/11-21-17-results.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-21-17-results.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-26-17-results-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-26-17-results.png"
  source       = "asset/posts/11-26-17-results.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-26-17-results.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-30-17-mongodb-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-30-17-mongodb.png"
  source       = "asset/posts/12-30-17-mongodb.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-30-17-mongodb.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-30-17-restapi-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-30-17-restapi.png"
  source       = "asset/posts/12-30-17-restapi.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-30-17-restapi.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-30-17-xmlresponse-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-30-17-xmlresponse.png"
  source       = "asset/posts/12-30-17-xmlresponse.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-30-17-xmlresponse.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-30-17-xmlresponsetext-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-30-17-xmlresponsetext.png"
  source       = "asset/posts/12-30-17-xmlresponsetext.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-30-17-xmlresponsetext.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-14-18-html-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-14-18-html.png"
  source       = "asset/posts/1-14-18-html.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-14-18-html.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-14-18-webresult-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-14-18-webresult.png"
  source       = "asset/posts/1-14-18-webresult.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-14-18-webresult.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-27-17-postlazy-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-27-17-postlazy.png"
  source       = "asset/posts/1-27-17-postlazy.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-27-17-postlazy.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-27-17-prelazy-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-27-17-prelazy.png"
  source       = "asset/posts/1-27-17-prelazy.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-27-17-prelazy.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-5-20-18-blockchain-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/5-20-18-blockchain.png"
  source       = "asset/posts/5-20-18-blockchain.png"
  etag         = filemd5("${path.cwd}/asset/posts/5-20-18-blockchain.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-5-20-18-simpleblock-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/5-20-18-simpleblock.png"
  source       = "asset/posts/5-20-18-simpleblock.png"
  etag         = filemd5("${path.cwd}/asset/posts/5-20-18-simpleblock.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-5-20-18-exercise-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/5-20-18-exercise.png"
  source       = "asset/posts/5-20-18-exercise.png"
  etag         = filemd5("${path.cwd}/asset/posts/5-20-18-exercise.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-5-31-18-seed-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/5-31-18-seed.png"
  source       = "asset/posts/5-31-18-seed.png"
  etag         = filemd5("${path.cwd}/asset/posts/5-31-18-seed.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-9-18-array-chain-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-9-18-array-chain.png"
  source       = "asset/posts/6-9-18-array-chain.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-9-18-array-chain.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-9-18-function-chain-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-9-18-function-chain.png"
  source       = "asset/posts/6-9-18-function-chain.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-9-18-function-chain.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-9-18-object-chain-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-9-18-object-chain.png"
  source       = "asset/posts/6-9-18-object-chain.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-9-18-object-chain.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-9-18-prototype-traverse-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-9-18-prototype-traverse.png"
  source       = "asset/posts/6-9-18-prototype-traverse.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-9-18-prototype-traverse.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-13-18-network-files-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-13-18-network-files.png"
  source       = "asset/posts/6-13-18-network-files.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-13-18-network-files.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-13-18-writing-notes-gif" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-13-18-writing-notes.gif"
  source       = "asset/posts/6-13-18-writing-notes.gif"
  etag         = filemd5("${path.cwd}/asset/posts/6-13-18-writing-notes.gif")
  content_type = "image/gif"
}

resource "aws_s3_object" "posts-6-18-18-grid-0-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-18-18-grid-0.png"
  source       = "asset/posts/6-18-18-grid-0.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-18-18-grid-0.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-18-18-grid-1-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-18-18-grid-1.png"
  source       = "asset/posts/6-18-18-grid-1.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-18-18-grid-1.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-18-18-grid-2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-18-18-grid-2.png"
  source       = "asset/posts/6-18-18-grid-2.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-18-18-grid-2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-4-18-groovy-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-4-18-groovy-strict-type-check.png"
  source       = "asset/posts/7-4-18-groovy-strict-type-check.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-4-18-groovy-strict-type-check.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-5-18-graphql-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-5-18-graphql.png"
  source       = "asset/posts/8-5-18-graphql.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-5-18-graphql.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-8-18-graphiql-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-8-18-graphiql.png"
  source       = "asset/posts/8-8-18-graphiql.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-8-18-graphiql.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-5-18-restapi-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-5-18-restapi.png"
  source       = "asset/posts/8-5-18-restapi.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-5-18-restapi.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-3-18-aws-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-3-18-aws.png"
  source       = "asset/posts/9-3-18-aws.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-3-18-aws.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-3-18-web-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-3-18-web.png"
  source       = "asset/posts/9-3-18-web.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-3-18-web.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-7-18-serverless-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-7-18-serverless.png"
  source       = "asset/posts/9-7-18-serverless.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-7-18-serverless.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-21-18-jenkins01-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-21-18-jenkins01.png"
  source       = "asset/posts/9-21-18-jenkins01.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-21-18-jenkins01.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-21-18-jenkins02-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-21-18-jenkins02.png"
  source       = "asset/posts/9-21-18-jenkins02.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-21-18-jenkins02.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-21-18-jenkins03-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-21-18-jenkins03.png"
  source       = "asset/posts/9-21-18-jenkins03.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-21-18-jenkins03.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-21-18-jenkins04-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-21-18-jenkins04.png"
  source       = "asset/posts/9-21-18-jenkins04.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-21-18-jenkins04.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-21-18-jenkins05-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-21-18-jenkins05.png"
  source       = "asset/posts/9-21-18-jenkins05.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-21-18-jenkins05.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-7-18-bar-chart-gif" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-7-18-bar-chart.gif"
  source       = "asset/posts/11-7-18-bar-chart.gif"
  etag         = filemd5("${path.cwd}/asset/posts/11-7-18-bar-chart.gif")
  content_type = "image/gif"
}

resource "aws_s3_object" "posts-11-24-18-angular-lifecycle-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-24-18-angular-lifecycle.png"
  source       = "asset/posts/11-24-18-angular-lifecycle.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-24-18-angular-lifecycle.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-22-18-hierarchy1-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-22-18-hierarchy1.png"
  source       = "asset/posts/12-22-18-hierarchy1.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-22-18-hierarchy1.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-22-18-hierarchy2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-22-18-hierarchy2.png"
  source       = "asset/posts/12-22-18-hierarchy2.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-22-18-hierarchy2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-22-18-hierarchy3-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-22-18-hierarchy3.png"
  source       = "asset/posts/12-22-18-hierarchy3.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-22-18-hierarchy3.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-19-19-react-lifecycles-gif" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-19-19-react-lifecycles.gif"
  source       = "asset/posts/1-19-19-react-lifecycles.gif"
  etag         = filemd5("${path.cwd}/asset/posts/1-19-19-react-lifecycles.gif")
  content_type = "image/gif"
}

resource "aws_s3_object" "posts-1-24-19-example-1-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-24-19-example-1.png"
  source       = "asset/posts/1-24-19-example-1.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-24-19-example-1.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-24-19-example-2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-24-19-example-2.png"
  source       = "asset/posts/1-24-19-example-2.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-24-19-example-2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-24-19-example-3-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-24-19-example-3.png"
  source       = "asset/posts/1-24-19-example-3.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-24-19-example-3.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-29-19-horse-picture-1-jpg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-29-19-horse-picture-1.jpg"
  source       = "asset/posts/1-29-19-horse-picture-1.jpg"
  etag         = filemd5("${path.cwd}/asset/posts/1-29-19-horse-picture-1.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_object" "posts-1-29-19-horse-picture-2-jpg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-29-19-horse-picture-2.jpg"
  source       = "asset/posts/1-29-19-horse-picture-2.jpg"
  etag         = filemd5("${path.cwd}/asset/posts/1-29-19-horse-picture-2.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_object" "posts-3-12-19-cd-project-gif" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/3-12-19-cd-project.gif"
  source       = "asset/posts/3-12-19-cd-project.gif"
  etag         = filemd5("${path.cwd}/asset/posts/3-12-19-cd-project.gif")
  content_type = "image/gif"
}

resource "aws_s3_object" "posts-4-28-19-app-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/4-28-19-app.png"
  source       = "asset/posts/4-28-19-app.png"
  etag         = filemd5("${path.cwd}/asset/posts/4-28-19-app.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-5-13-19-k8s-master-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/5-13-19-k8s-master.png"
  source       = "asset/posts/5-13-19-k8s-master.png"
  etag         = filemd5("${path.cwd}/asset/posts/5-13-19-k8s-master.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-5-13-19-k8s-worker-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/5-13-19-k8s-worker.png"
  source       = "asset/posts/5-13-19-k8s-worker.png"
  etag         = filemd5("${path.cwd}/asset/posts/5-13-19-k8s-worker.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-5-13-19-k8s-cluster-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/5-13-19-k8s-cluster.png"
  source       = "asset/posts/5-13-19-k8s-cluster.png"
  etag         = filemd5("${path.cwd}/asset/posts/5-13-19-k8s-cluster.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-5-20-19-web-browser" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/5-20-19-web-browser.png"
  source       = "asset/posts/5-20-19-web-browser.png"
  etag         = filemd5("${path.cwd}/asset/posts/5-20-19-web-browser.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-5-20-19-aws-console" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/5-20-19-aws-console.png"
  source       = "asset/posts/5-20-19-aws-console.png"
  etag         = filemd5("${path.cwd}/asset/posts/5-20-19-aws-console.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-17-19-repos" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-17-19-repos.png"
  source       = "asset/posts/6-17-19-repos.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-17-19-repos.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-24-19-flexbox-1-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-24-19-flexbox-1.png"
  source       = "asset/posts/8-24-19-flexbox-1.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-24-19-flexbox-1.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-24-19-flexbox-2-gif" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-24-19-flexbox-2.gif"
  source       = "asset/posts/8-24-19-flexbox-2.gif"
  etag         = filemd5("${path.cwd}/asset/posts/8-24-19-flexbox-2.gif")
  content_type = "image/gif"
}

resource "aws_s3_object" "posts-8-24-19-flexbox-3-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-24-19-flexbox-3.png"
  source       = "asset/posts/8-24-19-flexbox-3.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-24-19-flexbox-3.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-24-19-flexbox-4-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-24-19-flexbox-4.png"
  source       = "asset/posts/8-24-19-flexbox-4.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-24-19-flexbox-4.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-24-19-flexbox-5-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-24-19-flexbox-5.png"
  source       = "asset/posts/8-24-19-flexbox-5.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-24-19-flexbox-5.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-3-19-rds-snapshot-console-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-3-19-rds-snapshot-console.png"
  source       = "asset/posts/9-3-19-rds-snapshot-console.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-3-19-rds-snapshot-console.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-3-19-saints-xctf-infra-diagram-1-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-3-19-saints-xctf-infra-diagram-1.png"
  source       = "asset/posts/9-3-19-saints-xctf-infra-diagram-1.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-3-19-saints-xctf-infra-diagram-1.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-3-19-saints-xctf-infra-diagram-2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-3-19-saints-xctf-infra-diagram-2.png"
  source       = "asset/posts/9-3-19-saints-xctf-infra-diagram-2.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-3-19-saints-xctf-infra-diagram-2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-3-19-saints-xctf-infra-diagram-3-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-3-19-saints-xctf-infra-diagram-3.png"
  source       = "asset/posts/9-3-19-saints-xctf-infra-diagram-3.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-3-19-saints-xctf-infra-diagram-3.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-3-19-saints-xctf-infra-diagram-4-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-3-19-saints-xctf-infra-diagram-4.png"
  source       = "asset/posts/9-3-19-saints-xctf-infra-diagram-4.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-3-19-saints-xctf-infra-diagram-4.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-5-19-rds-backup-lambda-1-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-5-19-rds-backup-lambda-1.png"
  source       = "asset/posts/9-5-19-rds-backup-lambda-1.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-5-19-rds-backup-lambda-1.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-5-19-rds-backup-lambda-2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-5-19-rds-backup-lambda-2.png"
  source       = "asset/posts/9-5-19-rds-backup-lambda-2.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-5-19-rds-backup-lambda-2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-5-19-rds-backup-lambda-3-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-5-19-rds-backup-lambda-3.png"
  source       = "asset/posts/9-5-19-rds-backup-lambda-3.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-5-19-rds-backup-lambda-3.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-15-19-aws-console-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-15-19-aws-console.png"
  source       = "asset/posts/9-15-19-aws-console.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-15-19-aws-console.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-15-19-kibana-create-doc-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-15-19-kibana-create-doc.png"
  source       = "asset/posts/9-15-19-kibana-create-doc.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-15-19-kibana-create-doc.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-15-19-kibana-index-put-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-15-19-kibana-index-put.png"
  source       = "asset/posts/9-15-19-kibana-index-put.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-15-19-kibana-index-put.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-15-19-kibana-search-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-15-19-kibana-search.png"
  source       = "asset/posts/9-15-19-kibana-search.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-15-19-kibana-search.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-15-19-kibana-ui-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-15-19-kibana-ui.png"
  source       = "asset/posts/9-15-19-kibana-ui.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-15-19-kibana-ui.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-10-18-19-kibana-analyzer-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/10-18-19-kibana-analyzer.png"
  source       = "asset/posts/10-18-19-kibana-analyzer.png"
  etag         = filemd5("${path.cwd}/asset/posts/10-18-19-kibana-analyzer.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-31-20-react-16-3-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-31-20-react-16-3.png"
  source       = "asset/posts/1-31-20-react-16-3.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-31-20-react-16-3.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-5-20-jest-output" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-5-20-jest-output.png"
  source       = "asset/posts/2-5-20-jest-output.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-5-20-jest-output.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-15-20-error-page-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-15-20-error-page.png"
  source       = "asset/posts/2-15-20-error-page.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-15-20-error-page.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-15-20-infrastructure-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-15-20-infrastructure.png"
  source       = "asset/posts/2-15-20-infrastructure.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-15-20-infrastructure.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-27-20-ec2-efs-architecture-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-27-20-ec2-efs-architecture.png"
  source       = "asset/posts/9-27-20-ec2-efs-architecture.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-27-20-ec2-efs-architecture.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-29-20-k8s-architecture-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-29-20-k8s-architecture.png"
  source       = "asset/posts/9-29-20-k8s-architecture.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-29-20-k8s-architecture.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-10-1-20-cost-detection-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/10-1-20-cost-detection.png"
  source       = "asset/posts/10-1-20-cost-detection.png"
  etag         = filemd5("${path.cwd}/asset/posts/10-1-20-cost-detection.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-5-20-aj-switch-gif" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-5-20-aj-switch.gif"
  source       = "asset/posts/11-5-20-aj-switch.gif"
  etag         = filemd5("${path.cwd}/asset/posts/11-5-20-aj-switch.gif")
  content_type = "image/gif"
}

resource "aws_s3_object" "posts-11-5-20-aj-switch-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-5-20-aj-switch.png"
  source       = "asset/posts/11-5-20-aj-switch.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-5-20-aj-switch.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-14-21-initial-architecture-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-14-21-initial-architecture.png"
  source       = "asset/posts/6-14-21-initial-architecture.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-14-21-initial-architecture.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-14-21-aws-lift-shift-architecture-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-14-21-aws-lift-shift-architecture.png"
  source       = "asset/posts/6-14-21-aws-lift-shift-architecture.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-14-21-aws-lift-shift-architecture.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-14-21-v2-architecture-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-14-21-v2-architecture.png"
  source       = "asset/posts/6-14-21-v2-architecture.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-14-21-v2-architecture.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-18-21-aws-architecture-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-18-21-aws-architecture.png"
  source       = "asset/posts/6-18-21-aws-architecture.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-18-21-aws-architecture.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-18-21-terraform-module-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-18-21-terraform-module.png"
  source       = "asset/posts/6-18-21-terraform-module.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-18-21-terraform-module.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-18-21-saints-xctf-com-asset-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-18-21-saints-xctf-com-asset.png"
  source       = "asset/posts/6-18-21-saints-xctf-com-asset.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-18-21-saints-xctf-com-asset.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-18-21-saints-xctf-com-uasset-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-18-21-saints-xctf-com-uasset.png"
  source       = "asset/posts/6-18-21-saints-xctf-com-uasset.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-18-21-saints-xctf-com-uasset.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-18-21-saints-xctf-com-auth-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-18-21-saints-xctf-com-auth.png"
  source       = "asset/posts/6-18-21-saints-xctf-com-auth.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-18-21-saints-xctf-com-auth.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-18-21-saints-xctf-com-fn-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-18-21-saints-xctf-com-fn.png"
  source       = "asset/posts/6-18-21-saints-xctf-com-fn.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-18-21-saints-xctf-com-fn.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-18-21-saints-xctf-database-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-18-21-saints-xctf-database.png"
  source       = "asset/posts/6-18-21-saints-xctf-database.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-18-21-saints-xctf-database.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-29-21-jss-class-names-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-29-21-jss-class-names.png"
  source       = "asset/posts/6-29-21-jss-class-names.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-29-21-jss-class-names.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-29-21-jss-demo-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-29-21-jss-demo.png"
  source       = "asset/posts/6-29-21-jss-demo.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-29-21-jss-demo.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-6-30-21-react-jss-alert-component-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/6-30-21-react-jss-alert-component.png"
  source       = "asset/posts/6-30-21-react-jss-alert-component.png"
  etag         = filemd5("${path.cwd}/asset/posts/6-30-21-react-jss-alert-component.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-3-21-dynamodb-aws-console-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-3-21-dynamodb-aws-console.png"
  source       = "asset/posts/7-3-21-dynamodb-aws-console.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-3-21-dynamodb-aws-console.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-26-21-aws-canaries-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-26-21-aws-canaries.png"
  source       = "asset/posts/7-26-21-aws-canaries.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-26-21-aws-canaries.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-26-21-aws-sign-in-canary-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-26-21-aws-sign-in-canary.png"
  source       = "asset/posts/7-26-21-aws-sign-in-canary.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-26-21-aws-sign-in-canary.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-26-21-synthetics-canary-architecture-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-26-21-synthetics-canary-architecture.png"
  source       = "asset/posts/7-26-21-synthetics-canary-architecture.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-26-21-synthetics-canary-architecture.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-31-21-dashboard-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-31-21-dashboard.png"
  source       = "asset/posts/7-31-21-dashboard.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-31-21-dashboard.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-31-21-dashboard-mobile-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-31-21-dashboard-mobile.png"
  source       = "asset/posts/7-31-21-dashboard-mobile.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-31-21-dashboard-mobile.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-31-21-graphql-query-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-31-21-graphql-query.png"
  source       = "asset/posts/7-31-21-graphql-query.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-31-21-graphql-query.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-31-21-graphql-query-2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-31-21-graphql-query-2.png"
  source       = "asset/posts/7-31-21-graphql-query-2.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-31-21-graphql-query-2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-31-21-infrastructure-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-31-21-infrastructure.png"
  source       = "asset/posts/7-31-21-infrastructure.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-31-21-infrastructure.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-31-21-jenkins-pipelines-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-31-21-jenkins-pipelines.png"
  source       = "asset/posts/7-31-21-jenkins-pipelines.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-31-21-jenkins-pipelines.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-31-21-jenkins-test-pipeline-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-31-21-jenkins-test-pipeline.png"
  source       = "asset/posts/7-31-21-jenkins-test-pipeline.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-31-21-jenkins-test-pipeline.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-31-21-repository-count-component-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-31-21-repository-count-component.png"
  source       = "asset/posts/7-31-21-repository-count-component.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-31-21-repository-count-component.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-7-31-21-total-commits-component-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/7-31-21-total-commits-component.png"
  source       = "asset/posts/7-31-21-total-commits-component.png"
  etag         = filemd5("${path.cwd}/asset/posts/7-31-21-total-commits-component.png")
  content_type = "image/png"
}

# In the short term, know that I love being here for you in whatever capacity you feel I can be.
# I also love all the support you give me, it truly does help me.
# If there are any more ways I can be there for you, just have someone let me know.

resource "aws_s3_object" "posts-8-11-21-cypress-browser-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-cypress-browser.png"
  source       = "asset/posts/8-11-21-cypress-browser.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-cypress-browser.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-cypress-directory-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-cypress-directory.png"
  source       = "asset/posts/8-11-21-cypress-directory.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-cypress-directory.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-cypress-executed-test-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-cypress-executed-test.png"
  source       = "asset/posts/8-11-21-cypress-executed-test.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-cypress-executed-test.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-cypress-test-runner-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-cypress-test-runner.png"
  source       = "asset/posts/8-11-21-cypress-test-runner.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-cypress-test-runner.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-saintsxctf-api-error-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-saintsxctf-api-error.png"
  source       = "asset/posts/8-11-21-saintsxctf-api-error.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-saintsxctf-api-error.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-saintsxctf-api-error-2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-saintsxctf-api-error-2.png"
  source       = "asset/posts/8-11-21-saintsxctf-api-error-2.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-saintsxctf-api-error-2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-saintsxctf-create-log-test-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-saintsxctf-create-log-test.png"
  source       = "asset/posts/8-11-21-saintsxctf-create-log-test.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-saintsxctf-create-log-test.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-saintsxctf-create-log-test-2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-saintsxctf-create-log-test-2.png"
  source       = "asset/posts/8-11-21-saintsxctf-create-log-test-2.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-saintsxctf-create-log-test-2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-saintsxctf-home-about-mobile-test-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-saintsxctf-home-about-mobile-test.png"
  source       = "asset/posts/8-11-21-saintsxctf-home-about-mobile-test.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-saintsxctf-home-about-mobile-test.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-saintsxctf-home-about-test-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-saintsxctf-home-about-test.png"
  source       = "asset/posts/8-11-21-saintsxctf-home-about-test.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-saintsxctf-home-about-test.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-saintsxctf-home-page-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-saintsxctf-home-page.png"
  source       = "asset/posts/8-11-21-saintsxctf-home-page.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-saintsxctf-home-page.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-saintsxctf-home-title-test-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-saintsxctf-home-title-test.png"
  source       = "asset/posts/8-11-21-saintsxctf-home-title-test.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-saintsxctf-home-title-test.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-saintsxctf-monthly-calendar-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-saintsxctf-monthly-calendar.png"
  source       = "asset/posts/8-11-21-saintsxctf-monthly-calendar.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-saintsxctf-monthly-calendar.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-11-21-saintsxctf-monthly-calendar-2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-11-21-saintsxctf-monthly-calendar-2.png"
  source       = "asset/posts/8-11-21-saintsxctf-monthly-calendar-2.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-11-21-saintsxctf-monthly-calendar-2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-24-21-shared-url-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-24-21-shared-url.png"
  source       = "asset/posts/9-24-21-shared-url.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-24-21-shared-url.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-9-24-21-reverse-proxy-infrastructure-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/9-24-21-reverse-proxy-infrastructure.png"
  source       = "asset/posts/9-24-21-reverse-proxy-infrastructure.png"
  etag         = filemd5("${path.cwd}/asset/posts/9-24-21-reverse-proxy-infrastructure.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-10-10-21-jarombek-com-k8s-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/10-10-21-jarombek-com-k8s.png"
  source       = "asset/posts/10-10-21-jarombek-com-k8s.png"
  etag         = filemd5("${path.cwd}/asset/posts/10-10-21-jarombek-com-k8s.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-10-10-21-kubernetes-test-jenkins-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/10-10-21-kubernetes-test-jenkins.png"
  source       = "asset/posts/10-10-21-kubernetes-test-jenkins.png"
  etag         = filemd5("${path.cwd}/asset/posts/10-10-21-kubernetes-test-jenkins.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-10-25-21-k8s-architecture-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/10-25-21-k8s-architecture.png"
  source       = "asset/posts/10-25-21-k8s-architecture.png"
  etag         = filemd5("${path.cwd}/asset/posts/10-25-21-k8s-architecture.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-dashboard-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-dashboard.png"
  source       = "asset/posts/11-1-21-saintsxctf-dashboard.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-dashboard.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-home-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-home.png"
  source       = "asset/posts/11-1-21-saintsxctf-home.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-home.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-register-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-register.png"
  source       = "asset/posts/11-1-21-saintsxctf-register.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-home.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-sign-in-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-sign-in.png"
  source       = "asset/posts/11-1-21-saintsxctf-sign-in.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-sign-in.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-log-1-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-log-1.png"
  source       = "asset/posts/11-1-21-saintsxctf-log-1.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-log-1.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-log-2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-log-2.png"
  source       = "asset/posts/11-1-21-saintsxctf-log-2.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-log-2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-profile-logs-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-profile-logs.png"
  source       = "asset/posts/11-1-21-saintsxctf-profile-logs.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-profile-logs.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-profile-calendar-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-profile-calendar.png"
  source       = "asset/posts/11-1-21-saintsxctf-profile-calendar.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-profile-calendar.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-profile-chart-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-profile-chart.png"
  source       = "asset/posts/11-1-21-saintsxctf-profile-chart.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-profile-chart.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-profile-stats-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-profile-stats.png"
  source       = "asset/posts/11-1-21-saintsxctf-profile-stats.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-profile-stats.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-profile-edit-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-profile-edit.png"
  source       = "asset/posts/11-1-21-saintsxctf-profile-edit.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-profile-edit.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-teams-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-teams.png"
  source       = "asset/posts/11-1-21-saintsxctf-teams.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-teams.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-group-logs-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-group-logs.png"
  source       = "asset/posts/11-1-21-saintsxctf-group-logs.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-group-logs.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-group-members-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-group-members.png"
  source       = "asset/posts/11-1-21-saintsxctf-group-members.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-group-members.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-group-leaderboard-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-group-leaderboard.png"
  source       = "asset/posts/11-1-21-saintsxctf-group-leaderboard.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-group-leaderboard.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-group-stats-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-group-stats.png"
  source       = "asset/posts/11-1-21-saintsxctf-group-stats.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-group-stats.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-admin-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-admin.png"
  source       = "asset/posts/11-1-21-saintsxctf-admin.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-admin.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-admin-edit-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-admin-edit.png"
  source       = "asset/posts/11-1-21-saintsxctf-admin-edit.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-admin-edit.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-admin-invite-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-admin-invite.png"
  source       = "asset/posts/11-1-21-saintsxctf-admin-invite.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-admin-invite.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-1-21-saintsxctf-admin-users-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-1-21-saintsxctf-admin-users.png"
  source       = "asset/posts/11-1-21-saintsxctf-admin-users.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-1-21-saintsxctf-admin-users.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-15-21-directory-structure-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-15-21-directory-structure.png"
  source       = "asset/posts/11-15-21-directory-structure.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-15-21-directory-structure.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-15-21-checkbox-component-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-15-21-checkbox-component.png"
  source       = "asset/posts/11-15-21-checkbox-component.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-15-21-checkbox-component.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-3-21-redux-components-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-3-21-redux-components.png"
  source       = "asset/posts/12-3-21-redux-components.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-3-21-redux-components.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-3-21-teams-page-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-3-21-teams-page.png"
  source       = "asset/posts/12-3-21-teams-page.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-3-21-teams-page.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-24-21-api-file-structure-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-24-21-api-file-structure.png"
  source       = "asset/posts/12-24-21-api-file-structure.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-24-21-api-file-structure.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-2-22-block-public-access-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-2-22-block-public-access.png"
  source       = "asset/posts/1-2-22-block-public-access.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-2-22-block-public-access.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-2-22-block-public-access-on-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-2-22-block-public-access-on.png"
  source       = "asset/posts/1-2-22-block-public-access-on.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-2-22-block-public-access-on.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-2-22-public-buckets-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-2-22-public-buckets.png"
  source       = "asset/posts/1-2-22-public-buckets.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-2-22-public-buckets.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-2-22-private-buckets-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-2-22-private-buckets.png"
  source       = "asset/posts/1-2-22-private-buckets.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-2-22-private-buckets.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-2-22-static-website-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-2-22-static-website.png"
  source       = "asset/posts/1-2-22-static-website.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-2-22-static-website.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-17-22-airflow-dag-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-17-22-airflow-dag.png"
  source       = "asset/posts/1-17-22-airflow-dag.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-17-22-airflow-dag.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-17-22-airflow-graph-view-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-17-22-airflow-graph-view.png"
  source       = "asset/posts/1-17-22-airflow-graph-view.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-17-22-airflow-graph-view.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-17-22-airflow-graph-view-click-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-17-22-airflow-graph-view-click.png"
  source       = "asset/posts/1-17-22-airflow-graph-view-click.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-17-22-airflow-graph-view-click.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-17-22-airflow-graph-view-hover-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-17-22-airflow-graph-view-hover.png"
  source       = "asset/posts/1-17-22-airflow-graph-view-hover.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-17-22-airflow-graph-view-hover.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-17-22-airflow-home-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-17-22-airflow-home.png"
  source       = "asset/posts/1-17-22-airflow-home.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-17-22-airflow-home.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-17-22-airflow-log-view-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-17-22-airflow-log-view.png"
  source       = "asset/posts/1-17-22-airflow-log-view.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-17-22-airflow-log-view.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-17-22-airflow-tree-view-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-17-22-airflow-tree-view.png"
  source       = "asset/posts/1-17-22-airflow-tree-view.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-17-22-airflow-tree-view.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-17-22-airflow-hello-world-dag-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-17-22-airflow-hello-world-dag.png"
  source       = "asset/posts/1-17-22-airflow-hello-world-dag.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-17-22-airflow-hello-world-dag.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-17-22-airflow-tag-search-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-17-22-airflow-tag-search.png"
  source       = "asset/posts/1-17-22-airflow-tag-search.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-17-22-airflow-tag-search.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-17-22-airflow-branch-dag-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-17-22-airflow-branch-dag.png"
  source       = "asset/posts/1-17-22-airflow-branch-dag.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-17-22-airflow-branch-dag.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-5-22-api-infrastructure-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-5-22-api-infrastructure.png"
  source       = "asset/posts/2-5-22-api-infrastructure.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-5-22-api-infrastructure.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-5-22-welcome-email-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-5-22-welcome-email.png"
  source       = "asset/posts/2-5-22-welcome-email.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-5-22-welcome-email.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-5-22-jenkins-job-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-5-22-jenkins-job.png"
  source       = "asset/posts/2-5-22-jenkins-job.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-5-22-jenkins-job.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-18-22-api-infrastructure-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-18-22-api-infrastructure.png"
  source       = "asset/posts/2-18-22-api-infrastructure.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-18-22-api-infrastructure.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-26-22-exercise-log-view-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-26-22-exercise-log-view.png"
  source       = "asset/posts/2-26-22-exercise-log-view.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-26-22-exercise-log-view.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-26-22-exercise-log-editing-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-26-22-exercise-log-editing.png"
  source       = "asset/posts/2-26-22-exercise-log-editing.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-26-22-exercise-log-editing.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-26-22-exercise-log-created-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-26-22-exercise-log-created.png"
  source       = "asset/posts/2-26-22-exercise-log-created.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-26-22-exercise-log-created.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-26-22-exercise-logs-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-26-22-exercise-logs.png"
  source       = "asset/posts/2-26-22-exercise-logs.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-26-22-exercise-logs.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-2-26-22-edit-exercise-log-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/2-26-22-edit-exercise-log.png"
  source       = "asset/posts/2-26-22-edit-exercise-log.png"
  etag         = filemd5("${path.cwd}/asset/posts/2-26-22-edit-exercise-log.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-3-12-22-feel-slider-gif" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/3-12-22-feel-slider.gif"
  source       = "asset/posts/3-12-22-feel-slider.gif"
  etag         = filemd5("${path.cwd}/asset/posts/3-12-22-feel-slider.gif")
  content_type = "image/gif"
}

resource "aws_s3_object" "posts-3-12-22-input-validation-gif" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/3-12-22-input-validation.gif"
  source       = "asset/posts/3-12-22-input-validation.gif"
  etag         = filemd5("${path.cwd}/asset/posts/3-12-22-input-validation.gif")
  content_type = "image/gif"
}

resource "aws_s3_object" "posts-3-27-22-homepage-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/3-27-22-homepage.png"
  source       = "asset/posts/3-27-22-homepage.png"
  etag         = filemd5("${path.cwd}/asset/posts/3-27-22-homepage.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-3-27-22-phpmyadmin-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/3-27-22-phpmyadmin.png"
  source       = "asset/posts/3-27-22-phpmyadmin.png"
  etag         = filemd5("${path.cwd}/asset/posts/3-27-22-phpmyadmin.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-3-27-22-query-result-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/3-27-22-query-result.png"
  source       = "asset/posts/3-27-22-query-result.png"
  etag         = filemd5("${path.cwd}/asset/posts/3-27-22-query-result.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-3-27-22-write-query-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/3-27-22-write-query.png"
  source       = "asset/posts/3-27-22-write-query.png"
  etag         = filemd5("${path.cwd}/asset/posts/3-27-22-write-query.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-3-27-22-infra-diagram-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/3-27-22-infra-diagram.png"
  source       = "asset/posts/3-27-22-infra-diagram.png"
  etag         = filemd5("${path.cwd}/asset/posts/3-27-22-infra-diagram.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-sign-in-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-sign-in.png"
  source       = "asset/posts/8-28-22-splunk-sign-in.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-sign-in.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-homepage-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-homepage.png"
  source       = "asset/posts/8-28-22-splunk-homepage.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-homepage.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-query-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-query.png"
  source       = "asset/posts/8-28-22-splunk-query.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-query.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-count-query-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-count-query.png"
  source       = "asset/posts/8-28-22-splunk-count-query.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-count-query.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-filter-query-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-filter-query.png"
  source       = "asset/posts/8-28-22-splunk-filter-query.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-filter-query.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-prior-queries-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-prior-queries.png"
  source       = "asset/posts/8-28-22-splunk-prior-queries.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-prior-queries.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-memory-chart-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-memory-chart.png"
  source       = "asset/posts/8-28-22-splunk-memory-chart.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-memory-chart.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-add-data-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-add-data.png"
  source       = "asset/posts/8-28-22-splunk-add-data.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-add-data.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-upload-files-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-upload-files.png"
  source       = "asset/posts/8-28-22-splunk-upload-files.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-upload-files.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-custom-index-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-custom-index.png"
  source       = "asset/posts/8-28-22-splunk-custom-index.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-custom-index.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-http-codes-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-http-codes.png"
  source       = "asset/posts/8-28-22-splunk-http-codes.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-http-codes.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-dashboards-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-dashboards.png"
  source       = "asset/posts/8-28-22-splunk-dashboards.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-dashboards.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-internal-dashboard-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-internal-dashboard.png"
  source       = "asset/posts/8-28-22-splunk-internal-dashboard.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-internal-dashboard.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-dashboard-create-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-dashboard-create.png"
  source       = "asset/posts/8-28-22-splunk-dashboard-create.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-dashboard-create.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-8-28-22-splunk-dashboard-source-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/8-28-22-splunk-dashboard-source.png"
  source       = "asset/posts/8-28-22-splunk-dashboard-source.png"
  etag         = filemd5("${path.cwd}/asset/posts/8-28-22-splunk-dashboard-source.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-15-22-goland-run-config-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-15-22-goland-run-config.png"
  source       = "asset/posts/11-15-22-goland-run-config.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-15-22-goland-run-config.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-15-22-actions-tab-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-15-22-actions-tab.png"
  source       = "asset/posts/11-15-22-actions-tab.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-15-22-actions-tab.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-15-22-workflow-result-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-15-22-workflow-result.png"
  source       = "asset/posts/11-15-22-workflow-result.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-15-22-workflow-result.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-15-22-job-result-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-15-22-job-result.png"
  source       = "asset/posts/11-15-22-job-result.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-15-22-job-result.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-11-15-22-job-result-logs-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/11-15-22-job-result-logs.png"
  source       = "asset/posts/11-15-22-job-result-logs.png"
  etag         = filemd5("${path.cwd}/asset/posts/11-15-22-job-result-logs.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-12-11-22-summit-main-stage-jpg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-11-22-summit-main-stage.jpg"
  source       = "asset/posts/12-11-22-summit-main-stage.jpg"
  etag         = filemd5("${path.cwd}/asset/posts/12-11-22-summit-main-stage.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_object" "posts-12-11-22-databricks-workflow-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/12-11-22-databricks-workflow.png"
  source       = "asset/posts/12-11-22-databricks-workflow.png"
  etag         = filemd5("${path.cwd}/asset/posts/12-11-22-databricks-workflow.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-31-23-github-workflows-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-31-23-github-workflows.png"
  source       = "asset/posts/1-31-23-github-workflows.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-31-23-github-workflows.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-31-23-saintsxctf-infrastructure-flask-api-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-31-23-saintsxctf-infrastructure-flask-api.png"
  source       = "asset/posts/1-31-23-saintsxctf-infrastructure-flask-api.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-31-23-saintsxctf-infrastructure-flask-api.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-31-23-linting-formatting-workflow-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-31-23-linting-formatting-workflow.png"
  source       = "asset/posts/1-31-23-linting-formatting-workflow.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-31-23-linting-formatting-workflow.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-1-31-23-integration-test-workflow-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/1-31-23-integration-test-workflow.png"
  source       = "asset/posts/1-31-23-integration-test-workflow.png"
  etag         = filemd5("${path.cwd}/asset/posts/1-31-23-integration-test-workflow.png")
  content_type = "image/png"
}

resource "aws_s3_object" "posts-4-30-23-terraform-module-diagram-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "posts/4-30-23-terraform-module-diagram.png"
  source       = "asset/posts/4-30-23-terraform-module-diagram.png"
  etag         = filemd5("${path.cwd}/asset/posts/4-30-23-terraform-module-diagram.png")
  content_type = "image/png"
}

/*
 * Logos Directory
 */

resource "aws_s3_object" "airflow-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/airflow.png"
  source       = "asset/logos/airflow.png"
  etag         = filemd5("${path.cwd}/asset/logos/airflow.png")
  content_type = "image/png"
}

resource "aws_s3_object" "android-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/android.png"
  source       = "asset/logos/android.png"
  etag         = filemd5("${path.cwd}/asset/logos/android.png")
  content_type = "image/png"
}

resource "aws_s3_object" "angular-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/angular.png"
  source       = "asset/logos/angular.png"
  etag         = filemd5("${path.cwd}/asset/logos/angular.png")
  content_type = "image/png"
}

resource "aws_s3_object" "ansible-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/ansible.png"
  source       = "asset/logos/ansible.png"
  etag         = filemd5("${path.cwd}/asset/logos/ansible.png")
  content_type = "image/png"
}

resource "aws_s3_object" "apache-spark-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/apache-spark.png"
  source       = "asset/logos/apache-spark.png"
  etag         = filemd5("${path.cwd}/asset/logos/apache-spark.png")
  content_type = "image/png"
}

resource "aws_s3_object" "apigateway-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/apigateway.svg"
  source       = "asset/logos/apigateway.svg"
  etag         = filemd5("${path.cwd}/asset/logos/apigateway.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "assembly-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/assembly.png"
  source       = "asset/logos/assembly.png"
  etag         = filemd5("${path.cwd}/asset/logos/assembly.png")
  content_type = "image/png"
}

resource "aws_s3_object" "aws-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/aws.png"
  source       = "asset/logos/aws.png"
  etag         = filemd5("${path.cwd}/asset/logos/aws.png")
  content_type = "image/png"
}

resource "aws_s3_object" "aws-cloudfront-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/aws-cloudfront.svg"
  source       = "asset/logos/aws-cloudfront.svg"
  etag         = filemd5("${path.cwd}/asset/logos/aws-cloudfront.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "aws-cloudwatch-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/aws-cloudwatch.png"
  source       = "asset/logos/aws-cloudwatch.png"
  etag         = filemd5("${path.cwd}/asset/logos/aws-cloudwatch.png")
  content_type = "image/png"
}

resource "aws_s3_object" "aws-efs-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/aws-efs.png"
  source       = "asset/logos/aws-efs.png"
  etag         = filemd5("${path.cwd}/asset/logos/aws-efs.png")
  content_type = "image/png"
}

resource "aws_s3_object" "aws-iam-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/aws-iam.svg"
  source       = "asset/logos/aws-iam.svg"
  etag         = filemd5("${path.cwd}/asset/logos/aws-iam.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "aws-secrets-manager-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/aws-secrets-manager.png"
  source       = "asset/logos/aws-secrets-manager.png"
  etag         = filemd5("${path.cwd}/asset/logos/aws-secrets-manager.png")
  content_type = "image/png"
}

resource "aws_s3_object" "aws-vpc-endpoint-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/aws-vpc-endpoint.png"
  source       = "asset/logos/aws-vpc-endpoint.png"
  etag         = filemd5("${path.cwd}/asset/logos/aws-vpc-endpoint.png")
  content_type = "image/png"
}

resource "aws_s3_object" "awslambda-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/awslambda.png"
  source       = "asset/logos/awslambda.png"
  etag         = filemd5("${path.cwd}/asset/logos/awslambda.png")
  content_type = "image/png"
}

resource "aws_s3_object" "awsrds-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/awsrds.png"
  source       = "asset/logos/awsrds.png"
  etag         = filemd5("${path.cwd}/asset/logos/awsrds.png")
  content_type = "image/png"
}

resource "aws_s3_object" "awss3-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/awss3.svg"
  source       = "asset/logos/awss3.svg"
  etag         = filemd5("${path.cwd}/asset/logos/awss3.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "babel-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/babel.png"
  source       = "asset/logos/babel.png"
  etag         = filemd5("${path.cwd}/asset/logos/babel.png")
  content_type = "image/png"
}

resource "aws_s3_object" "batch-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/batch.png"
  source       = "asset/logos/batch.png"
  etag         = filemd5("${path.cwd}/asset/logos/batch.png")
  content_type = "image/png"
}

resource "aws_s3_object" "bash-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/bash.png"
  source       = "asset/logos/bash.png"
  etag         = filemd5("${path.cwd}/asset/logos/bash.png")
  content_type = "image/png"
}

resource "aws_s3_object" "bazel-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/bazel.svg"
  source       = "asset/logos/bazel.svg"
  etag         = filemd5("${path.cwd}/asset/logos/bazel.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "bootstrap-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/bootstrap.png"
  source       = "asset/logos/bootstrap.png"
  etag         = filemd5("${path.cwd}/asset/logos/bootstrap.png")
  content_type = "image/png"
}

resource "aws_s3_object" "c-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/c.png"
  source       = "asset/logos/c.png"
  etag         = filemd5("${path.cwd}/asset/logos/c.png")
  content_type = "image/png"
}

resource "aws_s3_object" "cloudformation-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/cloudformation.png"
  source       = "asset/logos/cloudformation.png"
  etag         = filemd5("${path.cwd}/asset/logos/cloudformation.png")
  content_type = "image/png"
}

resource "aws_s3_object" "cpp-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/cpp.png"
  source       = "asset/logos/cpp.png"
  etag         = filemd5("${path.cwd}/asset/logos/cpp.png")
  content_type = "image/png"
}

resource "aws_s3_object" "csharp-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/csharp.png"
  source       = "asset/logos/csharp.png"
  etag         = filemd5("${path.cwd}/asset/logos/csharp.png")
  content_type = "image/png"
}

resource "aws_s3_object" "css-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/css.png"
  source       = "asset/logos/css.png"
  etag         = filemd5("${path.cwd}/asset/logos/css.png")
  content_type = "image/png"
}

resource "aws_s3_object" "cypress-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/cypress.png"
  source       = "asset/logos/cypress.png"
  etag         = filemd5("${path.cwd}/asset/logos/cypress.png")
  content_type = "image/png"
}

resource "aws_s3_object" "docker-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/docker.png"
  source       = "asset/logos/docker.png"
  etag         = filemd5("${path.cwd}/asset/logos/docker.png")
  content_type = "image/png"
}

resource "aws_s3_object" "docker-compose-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/docker-compose.png"
  source       = "asset/logos/docker-compose.png"
  etag         = filemd5("${path.cwd}/asset/logos/docker-compose.png")
  content_type = "image/png"
}

resource "aws_s3_object" "dotnetcore-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/dotnetcore.png"
  source       = "asset/logos/dotnetcore.png"
  etag         = filemd5("${path.cwd}/asset/logos/dotnetcore.png")
  content_type = "image/png"
}

resource "aws_s3_object" "dynamodb-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/dynamodb.png"
  source       = "asset/logos/dynamodb.png"
  etag         = filemd5("${path.cwd}/asset/logos/dynamodb.png")
  content_type = "image/png"
}

resource "aws_s3_object" "d3-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/d3.png"
  source       = "asset/logos/d3.png"
  etag         = filemd5("${path.cwd}/asset/logos/d3.png")
  content_type = "image/png"
}

resource "aws_s3_object" "databricks-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/databricks.png"
  source       = "asset/logos/databricks.png"
  etag         = filemd5("${path.cwd}/asset/logos/databricks.png")
  content_type = "image/png"
}

resource "aws_s3_object" "ec2-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/ec2.png"
  source       = "asset/logos/ec2.png"
  etag         = filemd5("${path.cwd}/asset/logos/ec2.png")
  content_type = "image/png"
}

resource "aws_s3_object" "eks-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/eks.png"
  source       = "asset/logos/eks.png"
  etag         = filemd5("${path.cwd}/asset/logos/eks.png")
  content_type = "image/png"
}

resource "aws_s3_object" "elasticsearch-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/elasticsearch.png"
  source       = "asset/logos/elasticsearch.png"
  etag         = filemd5("${path.cwd}/asset/logos/elasticsearch.png")
  content_type = "image/png"
}

resource "aws_s3_object" "elk-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/elk.png"
  source       = "asset/logos/elk.png"
  etag         = filemd5("${path.cwd}/asset/logos/elk.png")
  content_type = "image/png"
}

resource "aws_s3_object" "enzyme-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/enzyme.png"
  source       = "asset/logos/enzyme.png"
  etag         = filemd5("${path.cwd}/asset/logos/enzyme.png")
  content_type = "image/png"
}

resource "aws_s3_object" "es6-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/es6.png"
  source       = "asset/logos/es6.png"
  etag         = filemd5("${path.cwd}/asset/logos/es6.png")
  content_type = "image/png"
}

resource "aws_s3_object" "es2017-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/es2017.png"
  source       = "asset/logos/es2017.png"
  etag         = filemd5("${path.cwd}/asset/logos/es2017.png")
  content_type = "image/png"
}

resource "aws_s3_object" "eslint-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/eslint.svg"
  source       = "asset/logos/eslint.svg"
  etag         = filemd5("${path.cwd}/asset/logos/eslint.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "express-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/express.png"
  source       = "asset/logos/express.png"
  etag         = filemd5("${path.cwd}/asset/logos/express.png")
  content_type = "image/png"
}

resource "aws_s3_object" "flask-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/flask.png"
  source       = "asset/logos/flask.png"
  etag         = filemd5("${path.cwd}/asset/logos/flask.png")
  content_type = "image/png"
}

resource "aws_s3_object" "flux-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/flux.png"
  source       = "asset/logos/flux.png"
  etag         = filemd5("${path.cwd}/asset/logos/flux.png")
  content_type = "image/png"
}

resource "aws_s3_object" "github-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/github.png"
  source       = "asset/logos/github.png"
  etag         = filemd5("${path.cwd}/asset/logos/github.png")
  content_type = "image/png"
}

resource "aws_s3_object" "github-actions-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/github-actions.png"
  source       = "asset/logos/github-actions.png"
  etag         = filemd5("${path.cwd}/asset/logos/github-actions.png")
  content_type = "image/png"
}

resource "aws_s3_object" "go-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/go.png"
  source       = "asset/logos/go.png"
  etag         = filemd5("${path.cwd}/asset/logos/go.png")
  content_type = "image/png"
}

resource "aws_s3_object" "goland-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/goland.png"
  source       = "asset/logos/goland.png"
  etag         = filemd5("${path.cwd}/asset/logos/goland.png")
  content_type = "image/png"
}

resource "aws_s3_object" "graphql-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/graphql.png"
  source       = "asset/logos/graphql.png"
  etag         = filemd5("${path.cwd}/asset/logos/graphql.png")
  content_type = "image/png"
}

resource "aws_s3_object" "groovy-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/groovy.png"
  source       = "asset/logos/groovy.png"
  etag         = filemd5("${path.cwd}/asset/logos/groovy.png")
  content_type = "image/png"
}

resource "aws_s3_object" "gulp-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/gulp.svg"
  source       = "asset/logos/gulp.svg"
  etag         = filemd5("${path.cwd}/asset/logos/gulp.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "haskell-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/haskell.png"
  source       = "asset/logos/haskell.png"
  etag         = filemd5("${path.cwd}/asset/logos/haskell.png")
  content_type = "image/png"
}

resource "aws_s3_object" "html-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/html.png"
  source       = "asset/logos/html.png"
  etag         = filemd5("${path.cwd}/asset/logos/html.png")
  content_type = "image/png"
}

resource "aws_s3_object" "ios-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/ios.png"
  source       = "asset/logos/ios.png"
  etag         = filemd5("${path.cwd}/asset/logos/ios.png")
  content_type = "image/png"
}

resource "aws_s3_object" "java-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/java.png"
  source       = "asset/logos/java.png"
  etag         = filemd5("${path.cwd}/asset/logos/java.png")
  content_type = "image/png"
}

resource "aws_s3_object" "java8-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/java8.png"
  source       = "asset/logos/java8.png"
  etag         = filemd5("${path.cwd}/asset/logos/java8.png")
  content_type = "image/png"
}

resource "aws_s3_object" "jenkins-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/jenkins.png"
  source       = "asset/logos/jenkins.png"
  etag         = filemd5("${path.cwd}/asset/logos/jenkins.png")
  content_type = "image/png"
}

resource "aws_s3_object" "jest-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/jest.svg"
  source       = "asset/logos/jest.svg"
  etag         = filemd5("${path.cwd}/asset/logos/jest.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "jquery-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/jquery.png"
  source       = "asset/logos/jquery.png"
  etag         = filemd5("${path.cwd}/asset/logos/jquery.png")
  content_type = "image/png"
}

resource "aws_s3_object" "js-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/js.png"
  source       = "asset/logos/js.png"
  etag         = filemd5("${path.cwd}/asset/logos/js.png")
  content_type = "image/png"
}

resource "aws_s3_object" "json-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/json.png"
  source       = "asset/logos/json.png"
  etag         = filemd5("${path.cwd}/asset/logos/json.png")
  content_type = "image/png"
}

resource "aws_s3_object" "jss-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/jss.png"
  source       = "asset/logos/jss.png"
  etag         = filemd5("${path.cwd}/asset/logos/jss.png")
  content_type = "image/png"
}

resource "aws_s3_object" "jwt-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/jwt.png"
  source       = "asset/logos/jwt.png"
  etag         = filemd5("${path.cwd}/asset/logos/jwt.png")
  content_type = "image/png"
}

resource "aws_s3_object" "k8s-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/k8s.png"
  source       = "asset/logos/k8s.png"
  etag         = filemd5("${path.cwd}/asset/logos/k8s.png")
  content_type = "image/png"
}

resource "aws_s3_object" "kibana-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/kibana.png"
  source       = "asset/logos/kibana.png"
  etag         = filemd5("${path.cwd}/asset/logos/kibana.png")
  content_type = "image/png"
}

resource "aws_s3_object" "less-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/less.png"
  source       = "asset/logos/less.png"
  etag         = filemd5("${path.cwd}/asset/logos/less.png")
  content_type = "image/png"
}

resource "aws_s3_object" "mongodb-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/mongodb.png"
  source       = "asset/logos/mongodb.png"
  etag         = filemd5("${path.cwd}/asset/logos/mongodb.png")
  content_type = "image/png"
}

resource "aws_s3_object" "mongoose-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/mongoose.png"
  source       = "asset/logos/mongoose.png"
  etag         = filemd5("${path.cwd}/asset/logos/mongoose.png")
  content_type = "image/png"
}

resource "aws_s3_object" "mysql-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/mysql.png"
  source       = "asset/logos/mysql.png"
  etag         = filemd5("${path.cwd}/asset/logos/mysql.png")
  content_type = "image/png"
}

resource "aws_s3_object" "neo4j-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/neo4j.png"
  source       = "asset/logos/neo4j.png"
  etag         = filemd5("${path.cwd}/asset/logos/neo4j.png")
  content_type = "image/png"
}

resource "aws_s3_object" "nginx-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/nginx.png"
  source       = "asset/logos/nginx.png"
  etag         = filemd5("${path.cwd}/asset/logos/nginx.png")
  content_type = "image/png"
}

resource "aws_s3_object" "nodejs-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/nodejs.png"
  source       = "asset/logos/nodejs.png"
  etag         = filemd5("${path.cwd}/asset/logos/nodejs.png")
  content_type = "image/png"
}

resource "aws_s3_object" "npm-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/npm.png"
  source       = "asset/logos/npm.png"
  etag         = filemd5("${path.cwd}/asset/logos/npm.png")
  content_type = "image/png"
}

resource "aws_s3_object" "numpy-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/numpy.png"
  source       = "asset/logos/numpy.png"
  etag         = filemd5("${path.cwd}/asset/logos/numpy.png")
  content_type = "image/png"
}

resource "aws_s3_object" "oracle-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/oracle.png"
  source       = "asset/logos/oracle.png"
  etag         = filemd5("${path.cwd}/asset/logos/oracle.png")
  content_type = "image/png"
}

resource "aws_s3_object" "packer-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/packer.svg"
  source       = "asset/logos/packer.svg"
  etag         = filemd5("${path.cwd}/asset/logos/packer.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "pandas-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/pandas.png"
  source       = "asset/logos/pandas.png"
  etag         = filemd5("${path.cwd}/asset/logos/pandas.png")
  content_type = "image/png"
}

resource "aws_s3_object" "php-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/php.svg"
  source       = "asset/logos/php.svg"
  etag         = filemd5("${path.cwd}/asset/logos/php.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "please-build-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/please-build.png"
  source       = "asset/logos/please-build.png"
  etag         = filemd5("${path.cwd}/asset/logos/please-build.png")
  content_type = "image/png"
}

resource "aws_s3_object" "powershell-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/powershell.png"
  source       = "asset/logos/powershell.png"
  etag         = filemd5("${path.cwd}/asset/logos/powershell.png")
  content_type = "image/png"
}

resource "aws_s3_object" "prettier-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/prettier.png"
  source       = "asset/logos/prettier.png"
  etag         = filemd5("${path.cwd}/asset/logos/prettier.png")
  content_type = "image/png"
}

resource "aws_s3_object" "puppeteer-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/puppeteer.png"
  source       = "asset/logos/puppeteer.png"
  etag         = filemd5("${path.cwd}/asset/logos/puppeteer.png")
  content_type = "image/png"
}

resource "aws_s3_object" "python-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/python.png"
  source       = "asset/logos/python.png"
  etag         = filemd5("${path.cwd}/asset/logos/python.png")
  content_type = "image/png"
}

resource "aws_s3_object" "r-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/r.png"
  source       = "asset/logos/r.png"
  etag         = filemd5("${path.cwd}/asset/logos/r.png")
  content_type = "image/png"
}

resource "aws_s3_object" "rabbitmq-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/rabbitmq.png"
  source       = "asset/logos/rabbitmq.png"
  etag         = filemd5("${path.cwd}/asset/logos/rabbitmq.png")
  content_type = "image/png"
}

resource "aws_s3_object" "react-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/react.png"
  source       = "asset/logos/react.png"
  etag         = filemd5("${path.cwd}/asset/logos/react.png")
  content_type = "image/png"
}

resource "aws_s3_object" "redux-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/redux.png"
  source       = "asset/logos/redux.png"
  etag         = filemd5("${path.cwd}/asset/logos/redux.png")
  content_type = "image/png"
}

resource "aws_s3_object" "sass-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/sass.png"
  source       = "asset/logos/sass.png"
  etag         = filemd5("${path.cwd}/asset/logos/sass.png")
  content_type = "image/png"
}

resource "aws_s3_object" "selenium-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/selenium.png"
  source       = "asset/logos/selenium.png"
  etag         = filemd5("${path.cwd}/asset/logos/selenium.png")
  content_type = "image/png"
}

resource "aws_s3_object" "splunk-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/splunk.png"
  source       = "asset/logos/splunk.png"
  etag         = filemd5("${path.cwd}/asset/logos/splunk.png")
  content_type = "image/png"
}

resource "aws_s3_object" "sql-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/sql.png"
  source       = "asset/logos/sql.png"
  etag         = filemd5("${path.cwd}/asset/logos/sql.png")
  content_type = "image/png"
}

resource "aws_s3_object" "sql-server-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/sql-server.svg"
  source       = "asset/logos/sql-server.svg"
  etag         = filemd5("${path.cwd}/asset/logos/sql-server.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "swift-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/swift.png"
  source       = "asset/logos/swift.png"
  etag         = filemd5("${path.cwd}/asset/logos/swift.png")
  content_type = "image/png"
}

resource "aws_s3_object" "swiftui-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/swiftui.png"
  source       = "asset/logos/swiftui.png"
  etag         = filemd5("${path.cwd}/asset/logos/swiftui.png")
  content_type = "image/png"
}

resource "aws_s3_object" "tech-logos-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/tech_logos.svg"
  source       = "asset/logos/tech_logos.svg"
  etag         = filemd5("${path.cwd}/asset/logos/tech_logos.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "tech-logos-white-svg" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/tech_logos_white.svg"
  source       = "asset/logos/tech_logos_white.svg"
  etag         = filemd5("${path.cwd}/asset/logos/tech_logos_white.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "terraform-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/terraform.png"
  source       = "asset/logos/terraform.png"
  etag         = filemd5("${path.cwd}/asset/logos/terraform.png")
  content_type = "image/png"
}

resource "aws_s3_object" "travisci-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/travisci.png"
  source       = "asset/logos/travisci.png"
  etag         = filemd5("${path.cwd}/asset/logos/travisci.png")
  content_type = "image/png"
}

resource "aws_s3_object" "ts-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/ts.png"
  source       = "asset/logos/ts.png"
  etag         = filemd5("${path.cwd}/asset/logos/ts.png")
  content_type = "image/png"
}

resource "aws_s3_object" "unicode-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/unicode.png"
  source       = "asset/logos/unicode.png"
  etag         = filemd5("${path.cwd}/asset/logos/unicode.png")
  content_type = "image/png"
}

resource "aws_s3_object" "uwsgi-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/uwsgi.png"
  source       = "asset/logos/uwsgi.png"
  etag         = filemd5("${path.cwd}/asset/logos/uwsgi.png")
  content_type = "image/png"
}

resource "aws_s3_object" "vim-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/vim.png"
  source       = "asset/logos/vim.png"
  etag         = filemd5("${path.cwd}/asset/logos/vim.png")
  content_type = "image/png"
}

resource "aws_s3_object" "webassembly-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/webassembly.png"
  source       = "asset/logos/webassembly.png"
  etag         = filemd5("${path.cwd}/asset/logos/webassembly.png")
  content_type = "image/png"
}

resource "aws_s3_object" "webpack-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/webpack.png"
  source       = "asset/logos/webpack.png"
  etag         = filemd5("${path.cwd}/asset/logos/webpack.png")
  content_type = "image/png"
}

resource "aws_s3_object" "yaml-png" {
  bucket       = aws_s3_bucket.asset-jarombek.id
  key          = "logos/yaml.png"
  source       = "asset/logos/yaml.png"
  etag         = filemd5("${path.cwd}/asset/logos/yaml.png")
  content_type = "image/png"
}