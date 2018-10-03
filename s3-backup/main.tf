/**
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

resource "aws_s3_bucket" "mongodb-backup" {
  bucket = "jarombek-com-mongodb-backup"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    abort_incomplete_multipart_upload_days = 1

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      # Since this bucket has versioning enabled, specify that versions that are not the latest
      # will be expired and deleted after a certain number of days
      days = "${var.expiration_days}"
    }
  }
}