/*
 * Configure an S3 bucket
 * Author: Andrew Jarombek
 * Date: 9/12/2018
 */

locals {
  # A unique identifier for the S3 origin.  This is needed for CloudFront.
  s3_origin_id = "assetsJarombekCom"
}

resource "aws_s3_bucket" "assets-jarombek" {
  bucket = "assets.jarombek.com"
  acl = "public-read"
  policy = "${file("${path.module}/policy.json")}"

  tags {
    Name = "assets.jarombek.com"
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

resource "aws_s3_bucket" "www-assets-jarombek" {
  bucket = "www.assets.jarombek.com"
  acl = "public-read"
  policy = "${file("${path.module}/www-policy.json")}"

  tags {
    Name = "www.assets.jarombek.com"
  }

  website {
    redirect_all_requests_to = "https://assets.jarombek.com"
  }
}

resource "aws_cloudfront_distribution" "assets-jarombek-distribution" {
  origin {
    domain_name = "${aws_s3_bucket.assets-jarombek.bucket_regional_domain_name}"
    origin_id = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity =
        "${aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path}"
    }
  }

  # Whether the cloudfront distribution is enabled to accept uer requests
  enabled = true

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment = "assets.jarombek.com CloudFront Distribution"
  default_root_object = "index.json"

  # Extra CNAMEs for this distribution
  aliases = ["assets.jarombek.com"]

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

    target_origin_id = "${local.s3_origin_id}"

    # Which protocols to use which accessing items from CloudFront
    viewer_protocol_policy = "https-only"

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
    cloudfront_default_certificate = true
  }

  tags {
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "assets.jarombek.com origin access identity"
}

/*
 * S3 Bucket Contents
 */

/*
 * Root Directory
 */

resource "aws_s3_bucket_object" "jarombek-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "jarombek.png"
  source = "s3-assets/assets/jarombek.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/jarombek.png"))}"
}

resource "aws_s3_bucket_object" "blizzard-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "blizzard.png"
  source = "s3-assets/assets/blizzard.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/blizzard.png"))}"
}

resource "aws_s3_bucket_object" "bulk-insert-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "bulk-insert.png"
  source = "s3-assets/assets/bulk-insert.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/bulk-insert.png"))}"
}

resource "aws_s3_bucket_object" "common-user-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "common-user.png"
  source = "s3-assets/assets/common-user.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/common-user.png"))}"
}

resource "aws_s3_bucket_object" "computer-jpg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "computer.jpg"
  source = "s3-assets/assets/computer.jpg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/computer.jpg"))}"
}

resource "aws_s3_bucket_object" "database-er-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "Database-ER.png"
  source = "s3-assets/assets/Database-ER.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/Database-ER.png"))}"
}

resource "aws_s3_bucket_object" "diamond-uml-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "diamond-uml.png"
  source = "s3-assets/assets/diamond-uml.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/diamond-uml.png"))}"
}

resource "aws_s3_bucket_object" "down-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "down.png"
  source = "s3-assets/assets/down.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/down.png"))}"
}

resource "aws_s3_bucket_object" "down-black-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "down-black.png"
  source = "s3-assets/assets/down-black.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/down-black.png"))}"
}

resource "aws_s3_bucket_object" "dynamic-jsx-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "dynamic-jsx.png"
  source = "s3-assets/assets/dynamic-jsx.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/dynamic-jsx.png"))}"
}

resource "aws_s3_bucket_object" "error-message-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "error-message.png"
  source = "s3-assets/assets/error-message.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/error-message.png"))}"
}

resource "aws_s3_bucket_object" "flag-svg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "flag.svg"
  source = "s3-assets/assets/flag.svg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/flag.svg"))}"
}

resource "aws_s3_bucket_object" "home-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "home.png"
  source = "s3-assets/assets/home.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/home.png"))}"
}

resource "aws_s3_bucket_object" "jarombek-home-background-jpg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "jarombek-home-background.jpg"
  source = "s3-assets/assets/jarombek-home-background.jpg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/jarombek-home-background.jpg"))}"
}

resource "aws_s3_bucket_object" "mean-stack-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "MEAN-Stack.png"
  source = "s3-assets/assets/MEAN-Stack.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/MEAN-Stack.png"))}"
}

resource "aws_s3_bucket_object" "kayak-jpg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "kayak.jpg"
  source = "s3-assets/assets/kayak.jpg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/kayak.jpg"))}"
}

resource "aws_s3_bucket_object" "login-component-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "login-component.png"
  source = "s3-assets/assets/login-component.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/login-component.png"))}"
}

resource "aws_s3_bucket_object" "main-component-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "main-component.png"
  source = "s3-assets/assets/main-component.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/main-component.png"))}"
}

resource "aws_s3_bucket_object" "meowcat-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "meowcat.png"
  source = "s3-assets/assets/meowcat.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/meowcat.png"))}"
}

resource "aws_s3_bucket_object" "search-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "search.png"
  source = "s3-assets/assets/search.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/search.png"))}"
}

resource "aws_s3_bucket_object" "signup-component-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "signup-component.png"
  source = "s3-assets/assets/signup-component.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/signup-component.png"))}"
}

resource "aws_s3_bucket_object" "triangles-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "triangles.png"
  source = "s3-assets/assets/triangles.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/triangles.png"))}"
}

/*
 * Fonts Directory
 */

resource "aws_s3_bucket_object" "dyslexie-bold-ttf" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "fonts/dyslexie-bold.ttf"
  source = "s3-assets/assets/fonts/dyslexie-bold.ttf"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/fonts/dyslexie-bold.ttf"))}"
}

resource "aws_s3_bucket_object" "fantasque-sans-mono-bold-ttf" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "fonts/FantasqueSansMono-Bold.ttf"
  source = "s3-assets/assets/fonts/FantasqueSansMono-Bold.ttf"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/fonts/FantasqueSansMono-Bold.ttf"))}"
}

resource "aws_s3_bucket_object" "longway-regular-otf" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "fonts/Longway-Regular.otf"
  source = "s3-assets/assets/fonts/Longway-Regular.otf"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/fonts/Longway-Regular.otf"))}"
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-ttf" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "fonts/SylexiadSansThin.ttf"
  source = "s3-assets/assets/fonts/SylexiadSansThin.ttf"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/fonts/SylexiadSansThin.ttf"))}"
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-bold-ttf" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "fonts/SylexiadSansThin-Bold.ttf"
  source = "s3-assets/assets/fonts/SylexiadSansThin-Bold.ttf"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/fonts/SylexiadSansThin-Bold.ttf"))}"
}

/*
 * Posts Directory
 */

resource "aws_s3_bucket_object" "11-6-17-graph-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/11-6-17-FairfieldGraphImage.png"
  source = "s3-assets/assets/posts/11-6-17-FairfieldGraphImage.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/11-6-17-FairfieldGraphImage.png"))}"
}

resource "aws_s3_bucket_object" "11-13-17-prompt-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/11-13-17-prompt.png"
  source = "s3-assets/assets/posts/11-13-17-prompt.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/11-13-17-prompt.png"))}"
}

resource "aws_s3_bucket_object" "11-21-17-results-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/11-21-17-results.png"
  source = "s3-assets/assets/posts/11-21-17-results.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/11-21-17-results.png"))}"
}

resource "aws_s3_bucket_object" "11-26-17-results-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/11-26-17-results.png"
  source = "s3-assets/assets/posts/11-26-17-results.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/11-26-17-results.png"))}"
}

resource "aws_s3_bucket_object" "12-30-17-mongodb-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/12-30-17-mongodb.png"
  source = "s3-assets/assets/posts/12-30-17-mongodb.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/12-30-17-mongodb.png"))}"
}

resource "aws_s3_bucket_object" "12-30-17-restapi-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/12-30-17-restapi.png"
  source = "s3-assets/assets/posts/12-30-17-restapi.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/12-30-17-restapi.png"))}"
}

resource "aws_s3_bucket_object" "12-30-17-xmlresponse-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/12-30-17-xmlresponse.png"
  source = "s3-assets/assets/posts/12-30-17-xmlresponse.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/12-30-17-xmlresponse.png"))}"
}

resource "aws_s3_bucket_object" "12-30-17-xmlresponsetext-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/12-30-17-xmlresponsetext.png"
  source = "s3-assets/assets/posts/12-30-17-xmlresponsetext.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/12-30-17-xmlresponsetext.png"))}"
}

resource "aws_s3_bucket_object" "1-14-18-html-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/1-14-18-html.png"
  source = "s3-assets/assets/posts/1-14-18-html.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/1-14-18-html.png"))}"
}

resource "aws_s3_bucket_object" "1-14-18-webresult-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/1-14-18-webresult.png"
  source = "s3-assets/assets/posts/1-14-18-webresult.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/1-14-18-webresult.png"))}"
}

resource "aws_s3_bucket_object" "1-27-17-postlazy-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/1-27-17-postlazy.png"
  source = "s3-assets/assets/posts/1-27-17-postlazy.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/1-27-17-postlazy.png"))}"
}

resource "aws_s3_bucket_object" "1-27-17-prelazy-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/1-27-17-prelazy.png"
  source = "s3-assets/assets/posts/1-27-17-prelazy.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/1-27-17-prelazy.png"))}"
}

resource "aws_s3_bucket_object" "5-20-18-blockchain-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/5-20-18-blockchain.png"
  source = "s3-assets/assets/posts/5-20-18-blockchain.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/5-20-18-blockchain.png"))}"
}

resource "aws_s3_bucket_object" "5-20-18-simpleblock-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/5-20-18-simpleblock.png"
  source = "s3-assets/assets/posts/5-20-18-simpleblock.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/5-20-18-simpleblock.png"))}"
}

resource "aws_s3_bucket_object" "5-20-18-exercise-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/5-20-18-exercise.png"
  source = "s3-assets/assets/posts/5-20-18-exercise.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/5-20-18-exercise.png"))}"
}

resource "aws_s3_bucket_object" "5-31-18-seed-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/5-31-18-seed.png"
  source = "s3-assets/assets/posts/5-31-18-seed.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/5-31-18-seed.png"))}"
}

resource "aws_s3_bucket_object" "6-9-18-array-chain-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/6-9-18-array-chain.png"
  source = "s3-assets/assets/posts/6-9-18-array-chain.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/6-9-18-array-chain.png"))}"
}

resource "aws_s3_bucket_object" "6-9-18-function-chain-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/6-9-18-function-chain.png"
  source = "s3-assets/assets/posts/6-9-18-function-chain.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/6-9-18-function-chain.png"))}"
}

resource "aws_s3_bucket_object" "6-9-18-object-chain-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/6-9-18-object-chain.png"
  source = "s3-assets/assets/posts/6-9-18-object-chain.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/6-9-18-object-chain.png"))}"
}

resource "aws_s3_bucket_object" "6-9-18-prototype-traverse-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/6-9-18-prototype-traverse.png"
  source = "s3-assets/assets/posts/6-9-18-prototype-traverse.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/6-9-18-prototype-traverse.png"))}"
}

resource "aws_s3_bucket_object" "6-13-18-network-files-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/6-13-18-network-files.png"
  source = "s3-assets/assets/posts/6-13-18-network-files.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/6-13-18-network-files.png"))}"
}

resource "aws_s3_bucket_object" "6-13-18-writing-notes-gif" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/6-13-18-writing-notes.gif"
  source = "s3-assets/assets/posts/6-13-18-writing-notes.gif"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/6-13-18-writing-notes.gif"))}"
}

resource "aws_s3_bucket_object" "6-18-18-grid-0-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/6-18-18-grid-0.png"
  source = "s3-assets/assets/posts/6-18-18-grid-0.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/6-18-18-grid-0.png"))}"
}

resource "aws_s3_bucket_object" "6-18-18-grid-1-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/6-18-18-grid-1.png"
  source = "s3-assets/assets/posts/6-18-18-grid-1.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/6-18-18-grid-1.png"))}"
}

resource "aws_s3_bucket_object" "6-18-18-grid-2-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/6-18-18-grid-2.png"
  source = "s3-assets/assets/posts/6-18-18-grid-2.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/6-18-18-grid-2.png"))}"
}

resource "aws_s3_bucket_object" "7-4-18-groovy-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/7-4-18-groovy-strict-type-check.png"
  source = "s3-assets/assets/posts/7-4-18-groovy-strict-type-check.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/7-4-18-groovy-strict-type-check.png"))}"
}

resource "aws_s3_bucket_object" "8-5-18-graphql-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/8-5-18-graphql.png"
  source = "s3-assets/assets/posts/8-5-18-graphql.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/8-5-18-graphql.png"))}"
}

resource "aws_s3_bucket_object" "8-8-18-graphiql-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/8-8-18-graphiql.png"
  source = "s3-assets/assets/posts/8-8-18-graphiql.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/8-8-18-graphiql.png"))}"
}

resource "aws_s3_bucket_object" "8-5-18-restapi-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/8-5-18-restapi.png"
  source = "s3-assets/assets/posts/8-5-18-restapi.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/8-5-18-restapi.png"))}"
}

resource "aws_s3_bucket_object" "9-3-18-aws-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/9-3-18-aws.png"
  source = "s3-assets/assets/posts/9-3-18-aws.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/9-3-18-aws.png"))}"
}

resource "aws_s3_bucket_object" "9-3-18-web-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/9-3-18-web.png"
  source = "s3-assets/assets/posts/9-3-18-web.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/9-3-18-web.png"))}"
}

resource "aws_s3_bucket_object" "9-7-18-serverless-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/9-7-18-serverless.png"
  source = "s3-assets/assets/posts/9-7-18-serverless.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/9-7-18-serverless.png"))}"
}

resource "aws_s3_bucket_object" "9-21-18-jenkins01-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/9-21-18-jenkins01.png"
  source = "s3-assets/assets/posts/9-21-18-jenkins01.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/9-21-18-jenkins01.png"))}"
}

resource "aws_s3_bucket_object" "9-21-18-jenkins02-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/9-21-18-jenkins02.png"
  source = "s3-assets/assets/posts/9-21-18-jenkins02.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/9-21-18-jenkins02.png"))}"
}

resource "aws_s3_bucket_object" "9-21-18-jenkins03-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/9-21-18-jenkins03.png"
  source = "s3-assets/assets/posts/9-21-18-jenkins03.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/9-21-18-jenkins03.png"))}"
}

resource "aws_s3_bucket_object" "9-21-18-jenkins04-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/9-21-18-jenkins04.png"
  source = "s3-assets/assets/posts/9-21-18-jenkins04.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/9-21-18-jenkins04.png"))}"
}

resource "aws_s3_bucket_object" "9-21-18-jenkins05-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/9-21-18-jenkins05.png"
  source = "s3-assets/assets/posts/9-21-18-jenkins05.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/9-21-18-jenkins05.png"))}"
}

resource "aws_s3_bucket_object" "11-7-18-bar-chart-gif" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/11-7-18-bar-chart.gif"
  source = "s3-assets/assets/posts/11-7-18-bar-chart.gif"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/11-7-18-bar-chart.gif"))}"
}

resource "aws_s3_bucket_object" "11-24-18-angular-lifecycle-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/11-24-18-angular-lifecycle.png"
  source = "s3-assets/assets/posts/11-24-18-angular-lifecycle.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/11-24-18-angular-lifecycle.png"))}"
}

resource "aws_s3_bucket_object" "12-22-18-hierarchy1-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/12-22-18-hierarchy1.png"
  source = "s3-assets/assets/posts/12-22-18-hierarchy1.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/12-22-18-hierarchy1.png"))}"
}

resource "aws_s3_bucket_object" "12-22-18-hierarchy2-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/12-22-18-hierarchy2.png"
  source = "s3-assets/assets/posts/12-22-18-hierarchy2.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/12-22-18-hierarchy2.png"))}"
}

resource "aws_s3_bucket_object" "12-22-18-hierarchy3-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/12-22-18-hierarchy3.png"
  source = "s3-assets/assets/posts/12-22-18-hierarchy3.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/12-22-18-hierarchy3.png"))}"
}

resource "aws_s3_bucket_object" "1-19-19-react-lifecycles-gif" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/1-19-19-react-lifecycles.gif"
  source = "s3-assets/assets/posts/1-19-19-react-lifecycles.gif"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/1-19-19-react-lifecycles.gif"))}"
}

resource "aws_s3_bucket_object" "1-24-19-example-1-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/1-24-19-example-1.png"
  source = "s3-assets/assets/posts/1-24-19-example-1.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/1-24-19-example-1.png"))}"
}

resource "aws_s3_bucket_object" "1-24-19-example-2-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/1-24-19-example-2.png"
  source = "s3-assets/assets/posts/1-24-19-example-2.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/1-24-19-example-2.png"))}"
}

resource "aws_s3_bucket_object" "1-24-19-example-3-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/1-24-19-example-3.png"
  source = "s3-assets/assets/posts/1-24-19-example-3.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/1-24-19-example-3.png"))}"
}

resource "aws_s3_bucket_object" "1-29-19-horse-picture-1-jpg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/1-29-19-horse-picture-1.jpg"
  source = "s3-assets/assets/posts/1-29-19-horse-picture-1.jpg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/1-29-19-horse-picture-1.jpg"))}"
}

resource "aws_s3_bucket_object" "1-29-19-horse-picture-2-jpg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/1-29-19-horse-picture-2.jpg"
  source = "s3-assets/assets/posts/1-29-19-horse-picture-2.jpg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/1-29-19-horse-picture-2.jpg"))}"
}

resource "aws_s3_bucket_object" "3-12-19-cd-project-gif" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/3-12-19-cd-project.gif"
  source = "s3-assets/assets/posts/3-12-19-cd-project.gif"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/3-12-19-cd-project.gif"))}"
}

resource "aws_s3_bucket_object" "4-28-19-app-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/4-28-19-app.png"
  source = "s3-assets/assets/posts/4-28-19-app.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/4-28-19-app.png"))}"
}

resource "aws_s3_bucket_object" "5-13-19-master-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/5-13-19-master.png"
  source = "s3-assets/assets/posts/5-13-19-master.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/5-13-19-master.png"))}"
}

resource "aws_s3_bucket_object" "5-13-19-worker-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/5-13-19-worker.png"
  source = "s3-assets/assets/posts/5-13-19-worker.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/5-13-19-worker.png"))}"
}

resource "aws_s3_bucket_object" "5-13-19-cluster-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/5-13-19-cluster.png"
  source = "s3-assets/assets/posts/5-13-19-cluster.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/5-13-19-cluster.png"))}"
}

resource "aws_s3_bucket_object" "5-20-19-web-browser" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/5-20-19-web-browser.png"
  source = "s3-assets/assets/posts/5-20-19-web-browser.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/5-20-19-web-browser.png"))}"
}

resource "aws_s3_bucket_object" "5-20-19-aws-console" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "posts/5-20-19-aws-console.png"
  source = "s3-assets/assets/posts/5-20-19-aws-console.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/posts/5-20-19-aws-console.png"))}"
}

/*
 * Logos Directory
 */

resource "aws_s3_bucket_object" "angular-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/angular.png"
  source = "s3-assets/assets/logos/angular.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/angular.png"))}"
}

resource "aws_s3_bucket_object" "apigateway-svg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/apigateway.svg"
  source = "s3-assets/assets/logos/apigateway.svg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/apigateway.svg"))}"
}

resource "aws_s3_bucket_object" "assembly-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/assembly.png"
  source = "s3-assets/assets/logos/assembly.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/assembly.png"))}"
}

resource "aws_s3_bucket_object" "aws-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/aws.png"
  source = "s3-assets/assets/logos/aws.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/aws.png"))}"
}

resource "aws_s3_bucket_object" "awslambda-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/awslambda.png"
  source = "s3-assets/assets/logos/awslambda.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/awslambda.png"))}"
}

resource "aws_s3_bucket_object" "babel-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/babel.png"
  source = "s3-assets/assets/logos/babel.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/babel.png"))}"
}

resource "aws_s3_bucket_object" "batch-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/batch.png"
  source = "s3-assets/assets/logos/batch.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/batch.png"))}"
}

resource "aws_s3_bucket_object" "bash-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/bash.png"
  source = "s3-assets/assets/logos/bash.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/bash.png"))}"
}

resource "aws_s3_bucket_object" "bootstrap-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/bootstrap.png"
  source = "s3-assets/assets/logos/bootstrap.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/bootstrap.png"))}"
}

resource "aws_s3_bucket_object" "c-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/c.png"
  source = "s3-assets/assets/logos/c.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/c.png"))}"
}

resource "aws_s3_bucket_object" "cloudformation-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/cloudformation.png"
  source = "s3-assets/assets/logos/cloudformation.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/cloudformation.png"))}"
}

resource "aws_s3_bucket_object" "cpp-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/cpp.png"
  source = "s3-assets/assets/logos/cpp.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/cpp.png"))}"
}

resource "aws_s3_bucket_object" "csharp-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/csharp.png"
  source = "s3-assets/assets/logos/csharp.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/csharp.png"))}"
}

resource "aws_s3_bucket_object" "css-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/css.png"
  source = "s3-assets/assets/logos/css.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/css.png"))}"
}

resource "aws_s3_bucket_object" "docker-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/docker.png"
  source = "s3-assets/assets/logos/docker.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/docker.png"))}"
}

resource "aws_s3_bucket_object" "d3-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/d3.png"
  source = "s3-assets/assets/logos/d3.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/d3.png"))}"
}

resource "aws_s3_bucket_object" "ec2-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/ec2.png"
  source = "s3-assets/assets/logos/ec2.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/ec2.png"))}"
}

resource "aws_s3_bucket_object" "eks-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/eks.png"
  source = "s3-assets/assets/logos/eks.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/eks.png"))}"
}

resource "aws_s3_bucket_object" "es6-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/es6.png"
  source = "s3-assets/assets/logos/es6.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/es6.png"))}"
}

resource "aws_s3_bucket_object" "es2017-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/es2017.png"
  source = "s3-assets/assets/logos/es2017.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/es2017.png"))}"
}

resource "aws_s3_bucket_object" "express-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/express.png"
  source = "s3-assets/assets/logos/express.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/express.png"))}"
}

resource "aws_s3_bucket_object" "github-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/github.png"
  source = "s3-assets/assets/logos/github.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/github.png"))}"
}

resource "aws_s3_bucket_object" "graphql-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/graphql.png"
  source = "s3-assets/assets/logos/graphql.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/graphql.png"))}"
}

resource "aws_s3_bucket_object" "groovy-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/groovy.png"
  source = "s3-assets/assets/logos/groovy.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/groovy.png"))}"
}

resource "aws_s3_bucket_object" "gulp-svg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/gulp.svg"
  source = "s3-assets/assets/logos/gulp.svg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/gulp.svg"))}"
}

resource "aws_s3_bucket_object" "haskell-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/haskell.png"
  source = "s3-assets/assets/logos/haskell.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/haskell.png"))}"
}

resource "aws_s3_bucket_object" "html-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/html.png"
  source = "s3-assets/assets/logos/html.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/html.png"))}"
}

resource "aws_s3_bucket_object" "java-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/java.png"
  source = "s3-assets/assets/logos/java.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/java.png"))}"
}

resource "aws_s3_bucket_object" "java8-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/java8.png"
  source = "s3-assets/assets/logos/java8.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/java8.png"))}"
}

resource "aws_s3_bucket_object" "jenkins-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/jenkins.png"
  source = "s3-assets/assets/logos/jenkins.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/jenkins.png"))}"
}

resource "aws_s3_bucket_object" "js-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/js.png"
  source = "s3-assets/assets/logos/js.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/js.png"))}"
}

resource "aws_s3_bucket_object" "json-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/json.png"
  source = "s3-assets/assets/logos/json.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/json.png"))}"
}

resource "aws_s3_bucket_object" "jwt-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/jwt.png"
  source = "s3-assets/assets/logos/jwt.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/jwt.png"))}"
}

resource "aws_s3_bucket_object" "k8s-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/k8s.png"
  source = "s3-assets/assets/logos/k8s.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/k8s.png"))}"
}

resource "aws_s3_bucket_object" "mongodb-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/mongodb.png"
  source = "s3-assets/assets/logos/mongodb.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/mongodb.png"))}"
}

resource "aws_s3_bucket_object" "mongoose-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/mongoose.png"
  source = "s3-assets/assets/logos/mongoose.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/mongoose.png"))}"
}

resource "aws_s3_bucket_object" "neo4j-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/neo4j.png"
  source = "s3-assets/assets/logos/neo4j.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/neo4j.png"))}"
}

resource "aws_s3_bucket_object" "nodejs-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/nodejs.png"
  source = "s3-assets/assets/logos/nodejs.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/nodejs.png"))}"
}

resource "aws_s3_bucket_object" "oracle-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/oracle.png"
  source = "s3-assets/assets/logos/oracle.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/oracle.png"))}"
}

resource "aws_s3_bucket_object" "php-svg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/php.svg"
  source = "s3-assets/assets/logos/php.svg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/php.svg"))}"
}

resource "aws_s3_bucket_object" "powershell-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/powershell.png"
  source = "s3-assets/assets/logos/powershell.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/powershell.png"))}"
}

resource "aws_s3_bucket_object" "python-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/python.png"
  source = "s3-assets/assets/logos/python.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/python.png"))}"
}

resource "aws_s3_bucket_object" "rabbitmq-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/rabbitmq.png"
  source = "s3-assets/assets/logos/rabbitmq.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/rabbitmq.png"))}"
}

resource "aws_s3_bucket_object" "react-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/react.png"
  source = "s3-assets/assets/logos/react.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/react.png"))}"
}

resource "aws_s3_bucket_object" "sass-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/sass.png"
  source = "s3-assets/assets/logos/sass.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/sass.png"))}"
}

resource "aws_s3_bucket_object" "sql-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/sql.png"
  source = "s3-assets/assets/logos/sql.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/sql.png"))}"
}

resource "aws_s3_bucket_object" "swift-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/swift.png"
  source = "s3-assets/assets/logos/swift.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/swift.png"))}"
}

resource "aws_s3_bucket_object" "tech-logos-svg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/tech_logos.svg"
  source = "s3-assets/assets/logos/tech_logos.svg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/tech_logos.svg"))}"
}

resource "aws_s3_bucket_object" "tech-logos-white-svg" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/tech_logos_white.svg"
  source = "s3-assets/assets/logos/tech_logos_white.svg"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/tech_logos_white.svg"))}"
}

resource "aws_s3_bucket_object" "terraform-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/terraform.png"
  source = "s3-assets/assets/logos/terraform.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/terraform.png"))}"
}

resource "aws_s3_bucket_object" "travisci-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/travisci.png"
  source = "s3-assets/assets/logos/travisci.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/travisci.png"))}"
}

resource "aws_s3_bucket_object" "ts-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/ts.png"
  source = "s3-assets/assets/logos/ts.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/ts.png"))}"
}

resource "aws_s3_bucket_object" "unicode-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/unicode.png"
  source = "s3-assets/assets/logos/unicode.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/unicode.png"))}"
}

resource "aws_s3_bucket_object" "vim-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/vim.png"
  source = "s3-assets/assets/logos/vim.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/vim.png"))}"
}

resource "aws_s3_bucket_object" "webpack-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/webpack.png"
  source = "s3-assets/assets/logos/webpack.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/webpack.png"))}"
}

resource "aws_s3_bucket_object" "yaml-png" {
  bucket = "${aws_s3_bucket.assets-jarombek.id}"
  key = "logos/yaml.png"
  source = "s3-assets/assets/logos/yaml.png"
  etag = "${md5(file("${path.cwd}/s3-assets/assets/logos/yaml.png"))}"
}