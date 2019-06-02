/**
 * Assets for the website located on an S3 bucket.  The S3 bucket has the domain asset.jarombek.com
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/jarombek-com-assets"
    region = "us-east-1"
  }
}

data "aws_acm_certificate" "wildcard-jarombek-com-cert" {
  domain = "*.jarombek.com"
}

data "aws_acm_certificate" "wildcard-asset-jarombek-com-cert" {
  domain = "*.asset.jarombek.com"
}

resource "aws_s3_bucket" "asset-jarombek" {
  bucket = "asset.jarombek.com"
  acl = "public-read"
  policy = file(path.module + "/policy.json")

  tags = {
    Name = "asset.jarombek.com"
  }

  website {
    index_document = "jarombek.png"
    error_document = "jarombek.png"
  }

  cors_rule {
    allowed_origins = ["https://jarombek.com"]
    allowed_methods = ["POST", "PUT", "DELETE", "HEAD"]
    allowed_headers = ["*"]
  }

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
  }
}

resource "aws_s3_bucket" "www-asset-jarombek" {
  bucket = "www.asset.jarombek.com"
  acl = "public-read"
  policy = file(path.module + "/www-policy.json")

  tags = {
    Name = "www.asset.jarombek.com"
  }

  website {
    redirect_all_requests_to = "https://asset.jarombek.com"
  }
}

resource "aws_cloudfront_distribution" "asset-jarombek-distribution" {
  origin {
    domain_name = aws_s3_bucket.asset-jarombek.bucket_regional_domain_name
    origin_id = "origin-bucket-" + aws_s3_bucket.asset-jarombek.id

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

  comment = "asset.jarombek.com CloudFront Distribution"
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

    target_origin_id = "origin-bucket-" + aws_s3_bucket.asset-jarombek.id

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
    Name = "asset-jarombek-com-cloudfront"
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "asset.jarombek.com origin access identity"
}

resource "aws_cloudfront_distribution" "www-asset-jarombek-distribution" {
  origin {
    domain_name = aws_s3_bucket.www-asset-jarombek.bucket_regional_domain_name
    origin_id = "origin-bucket-" + aws_s3_bucket.www-asset-jarombek.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin-access-identity-www.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept user requests
  enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment = "www.asset.jarombek.com CloudFront Distribution"
  default_root_object = "jarombek.png"

  # Extra CNAMEs for this distribution
  aliases = ["www.asset.jarombek.com"]

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

    target_origin_id = "origin-bucket-" + aws_s3_bucket.asset-jarombek.id

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
    acm_certificate_arn = data.aws_acm_certificate.wildcard-asset-jarombek-com-cert.arn
    ssl_support_method = "sni-only"
  }

  tags = {
    Name = "www-asset-jarombek-com-cloudfront"
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity-www" {
  comment = "www.asset.jarombek.com origin access identity"
}

/*
 * S3 Bucket Contents
 */

/*
 * Root Directory
 */

resource "aws_s3_bucket_object" "jarombek-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "jarombek.png"
  source = "asset/jarombek.png"
  etag = filemd5(path.cwd + "/asset/jarombek.png")
}

resource "aws_s3_bucket_object" "blizzard-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "blizzard.png"
  source = "asset/blizzard.png"
  etag = filemd5(path.cwd + "/asset/blizzard.png")
}

resource "aws_s3_bucket_object" "bulk-insert-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "bulk-insert.png"
  source = "asset/bulk-insert.png"
  etag = filemd5(path.cwd + "/asset/bulk-insert.png")
}

resource "aws_s3_bucket_object" "common-user-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "common-user.png"
  source = "asset/common-user.png"
  etag = filemd5(path.cwd + "/asset/common-user.png")
}

resource "aws_s3_bucket_object" "computer-jpg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "computer.jpg"
  source = "asset/computer.jpg"
  etag = filemd5(path.cwd + "/asset/computer.jpg")
}

resource "aws_s3_bucket_object" "database-er-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "Database-ER.png"
  source = "asset/Database-ER.png"
  etag = filemd5(path.cwd + "/asset/Database-ER.png")
}

resource "aws_s3_bucket_object" "diamond-uml-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "diamond-uml.png"
  source = "asset/diamond-uml.png"
  etag = filemd5(path.cwd + "/asset/diamond-uml.png")
}

resource "aws_s3_bucket_object" "down-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "down.png"
  source = "asset/down.png"
  etag = filemd5(path.cwd + "/asset/down.png")
}

resource "aws_s3_bucket_object" "down-black-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "down-black.png"
  source = "asset/down-black.png"
  etag = filemd5(path.cwd + "/asset/down-black.png")
}

resource "aws_s3_bucket_object" "dynamic-jsx-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "dynamic-jsx.png"
  source = "asset/dynamic-jsx.png"
  etag = filemd5(path.cwd + "/asset/dynamic-jsx.png")
}

resource "aws_s3_bucket_object" "error-message-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "error-message.png"
  source = "asset/error-message.png"
  etag = filemd5(path.cwd + "/asset/error-message.png")
}

resource "aws_s3_bucket_object" "flag-svg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "flag.svg"
  source = "asset/flag.svg"
  etag = filemd5(path.cwd + "/asset/flag.svg")
}

resource "aws_s3_bucket_object" "home-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "home.png"
  source = "asset/home.png"
  etag = filemd5(path.cwd + "/asset/home.png")
}

resource "aws_s3_bucket_object" "jarombek-home-background-jpg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "jarombek-home-background.jpg"
  source = "asset/jarombek-home-background.jpg"
  etag = filemd5(path.cwd + "/asset/jarombek-home-background.jpg")
}

resource "aws_s3_bucket_object" "mean-stack-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "MEAN-Stack.png"
  source = "asset/MEAN-Stack.png"
  etag = filemd5(path.cwd + "/asset/MEAN-Stack.png")
}

resource "aws_s3_bucket_object" "kayak-jpg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "kayak.jpg"
  source = "asset/kayak.jpg"
  etag = filemd5(path.cwd + "/asset/kayak.jpg")
}

resource "aws_s3_bucket_object" "login-component-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "login-component.png"
  source = "asset/login-component.png"
  etag = filemd5(path.cwd + "/asset/login-component.png")
}

resource "aws_s3_bucket_object" "main-component-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "main-component.png"
  source = "asset/main-component.png"
  etag = filemd5(path.cwd + "/asset/main-component.png")
}

resource "aws_s3_bucket_object" "meowcat-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "meowcat.png"
  source = "asset/meowcat.png"
  etag = filemd5(path.cwd + "/asset/meowcat.png")
}

resource "aws_s3_bucket_object" "search-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "search.png"
  source = "asset/search.png"
  etag = filemd5(path.cwd + "/asset/search.png")
}

resource "aws_s3_bucket_object" "signup-component-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "signup-component.png"
  source = "asset/signup-component.png"
  etag = filemd5(path.cwd + "/asset/signup-component.png")
}

resource "aws_s3_bucket_object" "triangles-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "triangles.png"
  source = "asset/triangles.png"
  etag = filemd5(path.cwd + "/asset/triangles.png")
}

/*
 * Fonts Directory
 */

resource "aws_s3_bucket_object" "dyslexie-bold-ttf" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "fonts/dyslexie-bold.ttf"
  source = "asset/fonts/dyslexie-bold.ttf"
  etag = filemd5(path.cwd + "/asset/fonts/dyslexie-bold.ttf")
}

resource "aws_s3_bucket_object" "fantasque-sans-mono-bold-ttf" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "fonts/FantasqueSansMono-Bold.ttf"
  source = "asset/fonts/FantasqueSansMono-Bold.ttf"
  etag = filemd5(path.cwd + "/asset/fonts/FantasqueSansMono-Bold.ttf")
}

resource "aws_s3_bucket_object" "longway-regular-otf" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "fonts/Longway-Regular.otf"
  source = "asset/fonts/Longway-Regular.otf"
  etag = filemd5(path.cwd + "/asset/fonts/Longway-Regular.otf")
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-ttf" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "fonts/SylexiadSansThin.ttf"
  source = "asset/fonts/SylexiadSansThin.ttf"
  etag = filemd5(path.cwd + "/asset/fonts/SylexiadSansThin.ttf")
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-bold-ttf" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "fonts/SylexiadSansThin-Bold.ttf"
  source = "asset/fonts/SylexiadSansThin-Bold.ttf"
  etag = filemd5(path.cwd + "/asset/fonts/SylexiadSansThin-Bold.ttf")
}

/*
 * Posts Directory
 */

resource "aws_s3_bucket_object" "posts-11-6-17-graph-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/11-6-17-FairfieldGraphImage.png"
  source = "asset/posts/11-6-17-FairfieldGraphImage.png"
  etag = filemd5(path.cwd + "/asset/posts/11-6-17-FairfieldGraphImage.png")
}

resource "aws_s3_bucket_object" "posts-11-13-17-prompt-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/11-13-17-prompt.png"
  source = "asset/posts/11-13-17-prompt.png"
  etag = filemd5(path.cwd + "/asset/posts/11-13-17-prompt.png")
}

resource "aws_s3_bucket_object" "posts-11-21-17-results-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/11-21-17-results.png"
  source = "asset/posts/11-21-17-results.png"
  etag = filemd5(path.cwd + "/asset/posts/11-21-17-results.png")
}

resource "aws_s3_bucket_object" "posts-11-26-17-results-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/11-26-17-results.png"
  source = "asset/posts/11-26-17-results.png"
  etag = filemd5(path.cwd + "/asset/posts/11-26-17-results.png")
}

resource "aws_s3_bucket_object" "posts-12-30-17-mongodb-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/12-30-17-mongodb.png"
  source = "asset/posts/12-30-17-mongodb.png"
  etag = filemd5(path.cwd + "/asset/posts/12-30-17-mongodb.png")
}

resource "aws_s3_bucket_object" "posts-12-30-17-restapi-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/12-30-17-restapi.png"
  source = "asset/posts/12-30-17-restapi.png"
  etag = filemd5(path.cwd + "/asset/posts/12-30-17-restapi.png")
}

resource "aws_s3_bucket_object" "posts-12-30-17-xmlresponse-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/12-30-17-xmlresponse.png"
  source = "asset/posts/12-30-17-xmlresponse.png"
  etag = filemd5(path.cwd + "/asset/posts/12-30-17-xmlresponse.png")
}

resource "aws_s3_bucket_object" "posts-12-30-17-xmlresponsetext-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/12-30-17-xmlresponsetext.png"
  source = "asset/posts/12-30-17-xmlresponsetext.png"
  etag = filemd5(path.cwd + "/asset/posts/12-30-17-xmlresponsetext.png")
}

resource "aws_s3_bucket_object" "posts-1-14-18-html-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/1-14-18-html.png"
  source = "asset/posts/1-14-18-html.png"
  etag = filemd5(path.cwd + "/asset/posts/1-14-18-html.png")
}

resource "aws_s3_bucket_object" "posts-1-14-18-webresult-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/1-14-18-webresult.png"
  source = "asset/posts/1-14-18-webresult.png"
  etag = filemd5(path.cwd + "/asset/posts/1-14-18-webresult.png")
}

resource "aws_s3_bucket_object" "posts-1-27-17-postlazy-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/1-27-17-postlazy.png"
  source = "asset/posts/1-27-17-postlazy.png"
  etag = filemd5(path.cwd + "/asset/posts/1-27-17-postlazy.png")
}

resource "aws_s3_bucket_object" "posts-1-27-17-prelazy-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/1-27-17-prelazy.png"
  source = "asset/posts/1-27-17-prelazy.png"
  etag = filemd5(path.cwd + "/asset/posts/1-27-17-prelazy.png")
}

resource "aws_s3_bucket_object" "posts-5-20-18-blockchain-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/5-20-18-blockchain.png"
  source = "asset/posts/5-20-18-blockchain.png"
  etag = filemd5(path.cwd + "/asset/posts/5-20-18-blockchain.png")
}

resource "aws_s3_bucket_object" "posts-5-20-18-simpleblock-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/5-20-18-simpleblock.png"
  source = "asset/posts/5-20-18-simpleblock.png"
  etag = filemd5(path.cwd + "/asset/posts/5-20-18-simpleblock.png")
}

resource "aws_s3_bucket_object" "posts-5-20-18-exercise-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/5-20-18-exercise.png"
  source = "asset/posts/5-20-18-exercise.png"
  etag = filemd5(path.cwd + "/asset/posts/5-20-18-exercise.png")
}

resource "aws_s3_bucket_object" "posts-5-31-18-seed-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/5-31-18-seed.png"
  source = "asset/posts/5-31-18-seed.png"
  etag = filemd5(path.cwd + "/asset/posts/5-31-18-seed.png")
}

resource "aws_s3_bucket_object" "posts-6-9-18-array-chain-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/6-9-18-array-chain.png"
  source = "asset/posts/6-9-18-array-chain.png"
  etag = filemd5(path.cwd + "/asset/posts/6-9-18-array-chain.png")
}

resource "aws_s3_bucket_object" "posts-6-9-18-function-chain-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/6-9-18-function-chain.png"
  source = "asset/posts/6-9-18-function-chain.png"
  etag = filemd5(path.cwd + "/asset/posts/6-9-18-function-chain.png")
}

resource "aws_s3_bucket_object" "posts-6-9-18-object-chain-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/6-9-18-object-chain.png"
  source = "asset/posts/6-9-18-object-chain.png"
  etag = filemd5(path.cwd + "/asset/posts/6-9-18-object-chain.png")
}

resource "aws_s3_bucket_object" "posts-6-9-18-prototype-traverse-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/6-9-18-prototype-traverse.png"
  source = "asset/posts/6-9-18-prototype-traverse.png"
  etag = filemd5(path.cwd + "/asset/posts/6-9-18-prototype-traverse.png")
}

resource "aws_s3_bucket_object" "posts-6-13-18-network-files-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/6-13-18-network-files.png"
  source = "asset/posts/6-13-18-network-files.png"
  etag = filemd5(path.cwd + "/asset/posts/6-13-18-network-files.png")
}

resource "aws_s3_bucket_object" "posts-6-13-18-writing-notes-gif" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/6-13-18-writing-notes.gif"
  source = "asset/posts/6-13-18-writing-notes.gif"
  etag = filemd5(path.cwd + "/asset/posts/6-13-18-writing-notes.gif")
}

resource "aws_s3_bucket_object" "posts-6-18-18-grid-0-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/6-18-18-grid-0.png"
  source = "asset/posts/6-18-18-grid-0.png"
  etag = filemd5(path.cwd + "/asset/posts/6-18-18-grid-0.png")
}

resource "aws_s3_bucket_object" "posts-6-18-18-grid-1-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/6-18-18-grid-1.png"
  source = "asset/posts/6-18-18-grid-1.png"
  etag = filemd5(path.cwd + "/asset/posts/6-18-18-grid-1.png")
}

resource "aws_s3_bucket_object" "posts-6-18-18-grid-2-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/6-18-18-grid-2.png"
  source = "asset/posts/6-18-18-grid-2.png"
  etag = filemd5(path.cwd + "/asset/posts/6-18-18-grid-2.png")
}

resource "aws_s3_bucket_object" "posts-7-4-18-groovy-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/7-4-18-groovy-strict-type-check.png"
  source = "asset/posts/7-4-18-groovy-strict-type-check.png"
  etag = filemd5(path.cwd + "/asset/posts/7-4-18-groovy-strict-type-check.png")
}

resource "aws_s3_bucket_object" "posts-8-5-18-graphql-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/8-5-18-graphql.png"
  source = "asset/posts/8-5-18-graphql.png"
  etag = filemd5(path.cwd + "/asset/posts/8-5-18-graphql.png")
}

resource "aws_s3_bucket_object" "posts-8-8-18-graphiql-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/8-8-18-graphiql.png"
  source = "asset/posts/8-8-18-graphiql.png"
  etag = filemd5(path.cwd + "/asset/posts/8-8-18-graphiql.png")
}

resource "aws_s3_bucket_object" "posts-8-5-18-restapi-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/8-5-18-restapi.png"
  source = "asset/posts/8-5-18-restapi.png"
  etag = filemd5(path.cwd + "/asset/posts/8-5-18-restapi.png")
}

resource "aws_s3_bucket_object" "posts-9-3-18-aws-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/9-3-18-aws.png"
  source = "asset/posts/9-3-18-aws.png"
  etag = filemd5(path.cwd + "/asset/posts/9-3-18-aws.png")
}

resource "aws_s3_bucket_object" "posts-9-3-18-web-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/9-3-18-web.png"
  source = "asset/posts/9-3-18-web.png"
  etag = filemd5(path.cwd + "/asset/posts/9-3-18-web.png")
}

resource "aws_s3_bucket_object" "posts-9-7-18-serverless-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/9-7-18-serverless.png"
  source = "asset/posts/9-7-18-serverless.png"
  etag = filemd5(path.cwd + "/asset/posts/9-7-18-serverless.png")
}

resource "aws_s3_bucket_object" "posts-9-21-18-jenkins01-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/9-21-18-jenkins01.png"
  source = "asset/posts/9-21-18-jenkins01.png"
  etag = filemd5(path.cwd + "/asset/posts/9-21-18-jenkins01.png")
}

resource "aws_s3_bucket_object" "posts-9-21-18-jenkins02-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/9-21-18-jenkins02.png"
  source = "asset/posts/9-21-18-jenkins02.png"
  etag = filemd5(path.cwd + "/asset/posts/9-21-18-jenkins02.png")
}

resource "aws_s3_bucket_object" "posts-9-21-18-jenkins03-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/9-21-18-jenkins03.png"
  source = "asset/posts/9-21-18-jenkins03.png"
  etag = filemd5(path.cwd + "/asset/posts/9-21-18-jenkins03.png")
}

resource "aws_s3_bucket_object" "posts-9-21-18-jenkins04-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/9-21-18-jenkins04.png"
  source = "asset/posts/9-21-18-jenkins04.png"
  etag = filemd5(path.cwd + "/asset/posts/9-21-18-jenkins04.png")
}

resource "aws_s3_bucket_object" "posts-9-21-18-jenkins05-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/9-21-18-jenkins05.png"
  source = "asset/posts/9-21-18-jenkins05.png"
  etag = filemd5(path.cwd + "/asset/posts/9-21-18-jenkins05.png")
}

resource "aws_s3_bucket_object" "posts-11-7-18-bar-chart-gif" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/11-7-18-bar-chart.gif"
  source = "asset/posts/11-7-18-bar-chart.gif"
  etag = filemd5(path.cwd + "/asset/posts/11-7-18-bar-chart.gif")
}

resource "aws_s3_bucket_object" "posts-11-24-18-angular-lifecycle-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/11-24-18-angular-lifecycle.png"
  source = "asset/posts/11-24-18-angular-lifecycle.png"
  etag = filemd5(path.cwd + "/asset/posts/11-24-18-angular-lifecycle.png")
}

resource "aws_s3_bucket_object" "posts-12-22-18-hierarchy1-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/12-22-18-hierarchy1.png"
  source = "asset/posts/12-22-18-hierarchy1.png"
  etag = filemd5(path.cwd + "/asset/posts/12-22-18-hierarchy1.png")
}

resource "aws_s3_bucket_object" "posts-12-22-18-hierarchy2-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/12-22-18-hierarchy2.png"
  source = "asset/posts/12-22-18-hierarchy2.png"
  etag = filemd5(path.cwd + "/asset/posts/12-22-18-hierarchy2.png")
}

resource "aws_s3_bucket_object" "posts-12-22-18-hierarchy3-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/12-22-18-hierarchy3.png"
  source = "asset/posts/12-22-18-hierarchy3.png"
  etag = filemd5(path.cwd + "/asset/posts/12-22-18-hierarchy3.png")
}

resource "aws_s3_bucket_object" "posts-1-19-19-react-lifecycles-gif" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/1-19-19-react-lifecycles.gif"
  source = "asset/posts/1-19-19-react-lifecycles.gif"
  etag = filemd5(path.cwd + "/asset/posts/1-19-19-react-lifecycles.gif")
}

resource "aws_s3_bucket_object" "posts-1-24-19-example-1-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/1-24-19-example-1.png"
  source = "asset/posts/1-24-19-example-1.png"
  etag = filemd5(path.cwd + "/asset/posts/1-24-19-example-1.png")
}

resource "aws_s3_bucket_object" "posts-1-24-19-example-2-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/1-24-19-example-2.png"
  source = "asset/posts/1-24-19-example-2.png"
  etag = filemd5(path.cwd + "/asset/posts/1-24-19-example-2.png")
}

resource "aws_s3_bucket_object" "posts-1-24-19-example-3-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/1-24-19-example-3.png"
  source = "asset/posts/1-24-19-example-3.png"
  etag = filemd5(path.cwd + "/asset/posts/1-24-19-example-3.png")
}

resource "aws_s3_bucket_object" "posts-1-29-19-horse-picture-1-jpg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/1-29-19-horse-picture-1.jpg"
  source = "asset/posts/1-29-19-horse-picture-1.jpg"
  etag = filemd5(path.cwd + "/asset/posts/1-29-19-horse-picture-1.jpg")
}

resource "aws_s3_bucket_object" "posts-1-29-19-horse-picture-2-jpg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/1-29-19-horse-picture-2.jpg"
  source = "asset/posts/1-29-19-horse-picture-2.jpg"
  etag = filemd5(path.cwd + "/asset/posts/1-29-19-horse-picture-2.jpg")
}

resource "aws_s3_bucket_object" "posts-3-12-19-cd-project-gif" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/3-12-19-cd-project.gif"
  source = "asset/posts/3-12-19-cd-project.gif"
  etag = filemd5(path.cwd + "/asset/posts/3-12-19-cd-project.gif")
}

resource "aws_s3_bucket_object" "posts-4-28-19-app-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/4-28-19-app.png"
  source = "asset/posts/4-28-19-app.png"
  etag = filemd5(path.cwd + "/asset/posts/4-28-19-app.png")
}

resource "aws_s3_bucket_object" "posts-5-13-19-k8s-master-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/5-13-19-k8s-master.png"
  source = "asset/posts/5-13-19-k8s-master.png"
  etag = filemd5(path.cwd + "/asset/posts/5-13-19-k8s-master.png")
}

resource "aws_s3_bucket_object" "posts-5-13-19-k8s-worker-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/5-13-19-k8s-worker.png"
  source = "asset/posts/5-13-19-k8s-worker.png"
  etag = filemd5(path.cwd + "/asset/posts/5-13-19-k8s-worker.png")
}

resource "aws_s3_bucket_object" "posts-5-13-19-k8s-cluster-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/5-13-19-k8s-cluster.png"
  source = "asset/posts/5-13-19-k8s-cluster.png"
  etag = filemd5(path.cwd + "/asset/posts/5-13-19-k8s-cluster.png")
}

resource "aws_s3_bucket_object" "posts-5-20-19-web-browser" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/5-20-19-web-browser.png"
  source = "asset/posts/5-20-19-web-browser.png"
  etag = filemd5(path.cwd + "/asset/posts/5-20-19-web-browser.png")
}

resource "aws_s3_bucket_object" "posts-5-20-19-aws-console" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "posts/5-20-19-aws-console.png"
  source = "asset/posts/5-20-19-aws-console.png"
  etag = filemd5(path.cwd + "/asset/posts/5-20-19-aws-console.png")
}

/*
 * Logos Directory
 */

resource "aws_s3_bucket_object" "angular-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/angular.png"
  source = "asset/logos/angular.png"
  etag = filemd5(path.cwd + "/asset/logos/angular.png")
}

resource "aws_s3_bucket_object" "apigateway-svg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/apigateway.svg"
  source = "asset/logos/apigateway.svg"
  etag = filemd5(path.cwd + "/asset/logos/apigateway.svg")
}

resource "aws_s3_bucket_object" "assembly-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/assembly.png"
  source = "asset/logos/assembly.png"
  etag = filemd5(path.cwd + "/asset/logos/assembly.png")
}

resource "aws_s3_bucket_object" "aws-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/aws.png"
  source = "asset/logos/aws.png"
  etag = filemd5(path.cwd + "/asset/logos/aws.png")
}

resource "aws_s3_bucket_object" "awslambda-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/awslambda.png"
  source = "asset/logos/awslambda.png"
  etag = filemd5(path.cwd + "/asset/logos/awslambda.png")
}

resource "aws_s3_bucket_object" "babel-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/babel.png"
  source = "asset/logos/babel.png"
  etag = filemd5(path.cwd + "/asset/logos/babel.png")
}

resource "aws_s3_bucket_object" "batch-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/batch.png"
  source = "asset/logos/batch.png"
  etag = filemd5(path.cwd + "/asset/logos/batch.png")
}

resource "aws_s3_bucket_object" "bash-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/bash.png"
  source = "asset/logos/bash.png"
  etag = filemd5(path.cwd + "/asset/logos/bash.png")
}

resource "aws_s3_bucket_object" "bootstrap-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/bootstrap.png"
  source = "asset/logos/bootstrap.png"
  etag = filemd5(path.cwd + "/asset/logos/bootstrap.png")
}

resource "aws_s3_bucket_object" "c-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/c.png"
  source = "asset/logos/c.png"
  etag = filemd5(path.cwd + "/asset/logos/c.png")
}

resource "aws_s3_bucket_object" "cloudformation-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/cloudformation.png"
  source = "asset/logos/cloudformation.png"
  etag = filemd5(path.cwd + "/asset/logos/cloudformation.png")
}

resource "aws_s3_bucket_object" "cpp-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/cpp.png"
  source = "asset/logos/cpp.png"
  etag = filemd5(path.cwd + "/asset/logos/cpp.png")
}

resource "aws_s3_bucket_object" "csharp-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/csharp.png"
  source = "asset/logos/csharp.png"
  etag = filemd5(path.cwd + "/asset/logos/csharp.png")
}

resource "aws_s3_bucket_object" "css-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/css.png"
  source = "asset/logos/css.png"
  etag = filemd5(path.cwd + "/asset/logos/css.png")
}

resource "aws_s3_bucket_object" "docker-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/docker.png"
  source = "asset/logos/docker.png"
  etag = filemd5(path.cwd + "/asset/logos/docker.png")
}

resource "aws_s3_bucket_object" "d3-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/d3.png"
  source = "asset/logos/d3.png"
  etag = filemd5(path.cwd + "/asset/logos/d3.png")
}

resource "aws_s3_bucket_object" "ec2-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/ec2.png"
  source = "asset/logos/ec2.png"
  etag = filemd5(path.cwd + "/asset/logos/ec2.png")
}

resource "aws_s3_bucket_object" "eks-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/eks.png"
  source = "asset/logos/eks.png"
  etag = filemd5(path.cwd + "/asset/logos/eks.png")
}

resource "aws_s3_bucket_object" "es6-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/es6.png"
  source = "asset/logos/es6.png"
  etag = filemd5(path.cwd + "/asset/logos/es6.png")
}

resource "aws_s3_bucket_object" "es2017-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/es2017.png"
  source = "asset/logos/es2017.png"
  etag = filemd5(path.cwd + "/asset/logos/es2017.png")
}

resource "aws_s3_bucket_object" "express-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/express.png"
  source = "asset/logos/express.png"
  etag = filemd5(path.cwd + "/asset/logos/express.png")
}

resource "aws_s3_bucket_object" "github-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/github.png"
  source = "asset/logos/github.png"
  etag = filemd5(path.cwd + "/asset/logos/github.png")
}

resource "aws_s3_bucket_object" "graphql-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/graphql.png"
  source = "asset/logos/graphql.png"
  etag = filemd5(path.cwd + "/asset/logos/graphql.png")
}

resource "aws_s3_bucket_object" "groovy-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/groovy.png"
  source = "asset/logos/groovy.png"
  etag = filemd5(path.cwd + "/asset/logos/groovy.png")
}

resource "aws_s3_bucket_object" "gulp-svg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/gulp.svg"
  source = "asset/logos/gulp.svg"
  etag = filemd5(path.cwd + "/asset/logos/gulp.svg")
}

resource "aws_s3_bucket_object" "haskell-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/haskell.png"
  source = "asset/logos/haskell.png"
  etag = filemd5(path.cwd + "/asset/logos/haskell.png")
}

resource "aws_s3_bucket_object" "html-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/html.png"
  source = "asset/logos/html.png"
  etag = filemd5(path.cwd + "/asset/logos/html.png")
}

resource "aws_s3_bucket_object" "java-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/java.png"
  source = "asset/logos/java.png"
  etag = filemd5(path.cwd + "/asset/logos/java.png")
}

resource "aws_s3_bucket_object" "java8-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/java8.png"
  source = "asset/logos/java8.png"
  etag = filemd5(path.cwd + "/asset/logos/java8.png")
}

resource "aws_s3_bucket_object" "jenkins-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/jenkins.png"
  source = "asset/logos/jenkins.png"
  etag = filemd5(path.cwd + "/asset/logos/jenkins.png")
}

resource "aws_s3_bucket_object" "js-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/js.png"
  source = "asset/logos/js.png"
  etag = filemd5(path.cwd + "/asset/logos/js.png")
}

resource "aws_s3_bucket_object" "json-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/json.png"
  source = "asset/logos/json.png"
  etag = filemd5(path.cwd + "/asset/logos/json.png")
}

resource "aws_s3_bucket_object" "jwt-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/jwt.png"
  source = "asset/logos/jwt.png"
  etag = filemd5(path.cwd + "/asset/logos/jwt.png")
}

resource "aws_s3_bucket_object" "k8s-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/k8s.png"
  source = "asset/logos/k8s.png"
  etag = filemd5(path.cwd + "/asset/logos/k8s.png")
}

resource "aws_s3_bucket_object" "mongodb-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/mongodb.png"
  source = "asset/logos/mongodb.png"
  etag = filemd5(path.cwd + "/asset/logos/mongodb.png")
}

resource "aws_s3_bucket_object" "mongoose-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/mongoose.png"
  source = "asset/logos/mongoose.png"
  etag = filemd5(path.cwd + "/asset/logos/mongoose.png")
}

resource "aws_s3_bucket_object" "neo4j-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/neo4j.png"
  source = "asset/logos/neo4j.png"
  etag = filemd5(path.cwd + "/asset/logos/neo4j.png")
}

resource "aws_s3_bucket_object" "nodejs-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/nodejs.png"
  source = "asset/logos/nodejs.png"
  etag = filemd5(path.cwd + "/asset/logos/nodejs.png")
}

resource "aws_s3_bucket_object" "oracle-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/oracle.png"
  source = "asset/logos/oracle.png"
  etag = filemd5(path.cwd + "/asset/logos/oracle.png")
}

resource "aws_s3_bucket_object" "php-svg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/php.svg"
  source = "asset/logos/php.svg"
  etag = filemd5(path.cwd + "/asset/logos/php.svg")
}

resource "aws_s3_bucket_object" "powershell-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/powershell.png"
  source = "asset/logos/powershell.png"
  etag = filemd5(path.cwd + "/asset/logos/powershell.png")
}

resource "aws_s3_bucket_object" "python-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/python.png"
  source = "asset/logos/python.png"
  etag = filemd5(path.cwd + "/asset/logos/python.png")
}

resource "aws_s3_bucket_object" "rabbitmq-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/rabbitmq.png"
  source = "asset/logos/rabbitmq.png"
  etag = filemd5(path.cwd + "/asset/logos/rabbitmq.png")
}

resource "aws_s3_bucket_object" "react-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/react.png"
  source = "asset/logos/react.png"
  etag = filemd5(path.cwd + "/asset/logos/react.png")
}

resource "aws_s3_bucket_object" "sass-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/sass.png"
  source = "asset/logos/sass.png"
  etag = filemd5(path.cwd + "/asset/logos/sass.png")
}

resource "aws_s3_bucket_object" "sql-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/sql.png"
  source = "asset/logos/sql.png"
  etag = filemd5(path.cwd + "/asset/logos/sql.png")
}

resource "aws_s3_bucket_object" "swift-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/swift.png"
  source = "asset/logos/swift.png"
  etag = filemd5(path.cwd + "/asset/logos/swift.png")
}

resource "aws_s3_bucket_object" "tech-logos-svg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/tech_logos.svg"
  source = "asset/logos/tech_logos.svg"
  etag = filemd5(path.cwd + "/asset/logos/tech_logos.svg")
}

resource "aws_s3_bucket_object" "tech-logos-white-svg" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/tech_logos_white.svg"
  source = "asset/logos/tech_logos_white.svg"
  etag = filemd5(path.cwd + "/asset/logos/tech_logos_white.svg")
}

resource "aws_s3_bucket_object" "terraform-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/terraform.png"
  source = "asset/logos/terraform.png"
  etag = filemd5(path.cwd + "/asset/logos/terraform.png")
}

resource "aws_s3_bucket_object" "travisci-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/travisci.png"
  source = "asset/logos/travisci.png"
  etag = filemd5(path.cwd + "/asset/logos/travisci.png")
}

resource "aws_s3_bucket_object" "ts-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/ts.png"
  source = "asset/logos/ts.png"
  etag = filemd5(path.cwd + "/asset/logos/ts.png")
}

resource "aws_s3_bucket_object" "unicode-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/unicode.png"
  source = "asset/logos/unicode.png"
  etag = filemd5(path.cwd + "/asset/logos/unicode.png")
}

resource "aws_s3_bucket_object" "vim-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/vim.png"
  source = "asset/logos/vim.png"
  etag = filemd5(path.cwd + "/asset/logos/vim.png")
}

resource "aws_s3_bucket_object" "webpack-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/webpack.png"
  source = "asset/logos/webpack.png"
  etag = filemd5(path.cwd + "/asset/logos/webpack.png")
}

resource "aws_s3_bucket_object" "yaml-png" {
  bucket = aws_s3_bucket.asset-jarombek.id
  key = "logos/yaml.png"
  source = "asset/logos/yaml.png"
  etag = filemd5(path.cwd + "/asset/logos/yaml.png")
}