/**
 * DocumentDB backups on S3
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
}

#-------------
# S3 Resources
#-------------

resource "aws_s3_bucket" "saints-xctf-db-backups" {
  bucket = "jarombek-com-db-backups-${local.env}"

  # Bucket owner gets full control, nobody else has access
  acl = "private"

  policy = "${file("${path.module}/policies/policy-${local.env}.json")}"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 60
    }
  }

  tags {
    Name = "jarombek-com-db-backups-${local.env}"
  }
}