/**
 * Infrastructure for the jarombekcom mongodb database in the PROD environment
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
    key = "jarombek-com-infrastructure/database/env/prod"
    region = "us-east-1"
  }
}

module "rds" {
  source = "../../modules/mongodb"
  prod = true
  username = "${var.username}"
  password = "${var.password}"
}

module "s3" {
  source = "../../modules/s3-backup"
  prod = true
  expiration_days = 14
}