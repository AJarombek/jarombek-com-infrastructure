/**
 * Infrastructure for the jarombekcom mongodb database in the DEV environment
 * Author: Andrew Jarombek
 * Date: 3/20/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/database/env/dev"
    region = "us-east-1"
  }
}

module "mongodb" {
  source = "../../modules/mongodb"
  prod = false
}

module "s3" {
  source = "../../modules/s3-backup"
  prod = false
  expiration_days = 7
}