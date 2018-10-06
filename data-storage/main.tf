/**
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

provider "aws" {
  alias = "aws-us-east"
  region = "us-east-1"
}

# Provide credentials via the MONGODB_ATLAS_USERNAME and MONGODB_ATLAS_API_KEY environment variables
provider "mongodbatlas" {
  alias = "mongo"

  # Matches any non-beta version >= 0.6.0 and < 0.7.0
  # Specifying a version is reommended for third-party providers
  version = "~> 0.6"
}

data "aws_vpc" "jarombek-vpc" {
  tags {
    Name = "jarombek-com-vpc"
  }
}

module "mongodb" {
  source = "./mongodb"

  database_user_andy_password = "${var.mongodb_user_andy_password}"

  aws_region = "US-EAST-1"

  providers = {
    mongo = "mongodbatlas.mongo"
  }
}

module "s3-backup" {
  source = "./s3-backup"

  providers = {
    aws = "aws.aws-us-east"
  }
}

module "s3-tfstate" {
  source = "./s3-tfstate"

  providers = {
    aws = "aws.aws-us-east"
  }
}