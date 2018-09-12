/*
 * Configure an S3 bucket
 * Author: Andrew Jarombek
 * Date: 9/12/2018
 */

resource "aws_s3_bucket" "asset-jarombek" {
  bucket = "asset-jarombek"
  acl = "public-read"
  policy = "${file("policy.json")}"

  tags {
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
  bucket = "www-asset-jarombek"
  acl = "public-read"
  policy = "${file("www-policy.json")}"

  tags {
    Name = "www.asset.jarombek.com"
  }

  website {
    redirect_all_requests_to = "https://asset.jarombek.com"
  }
}

/*
 * S3 Bucket Contents
 */

/*
 * Root Directory
 */

resource "aws_s3_bucket_object" "jarombek-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "jarombek.png"
  source = "assets/jarombek.png"
  etag = "${md5(file("assets/jarombek.png"))}"
}

/*
 * Fonts Directory
 */

/*
 * Logos Directory
 */

/*
 * Posts Directory
 */