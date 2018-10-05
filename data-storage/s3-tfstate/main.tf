/**
 * Author: Andrew Jarombek
 * Date: 10/2/2018
 */

# Store the terraform state file in an S3 bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "jarombek-com-data-storage-tfstate"

  # Enable versioning, which means each change that is made to a file is visible and can be reverted back to
  versioning {
    enabled = true
  }

  # Calling terraform destroy on this resource will fail due to the lifecycle setting 'prevent destroy'
  lifecycle {
    prevent_destroy = true
  }
}