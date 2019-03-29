/**
 * Assets for the website located on an S3 bucket.  The S3 bucket has the domain assets.jarombek.com
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/jarombek-com-assets"
    region = "us-east-1"
  }
}

#------------------
# Terraform Modules
#------------------

module "s3-assets" {
  source = "./s3-assets"
}