/**
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

provider "aws" {
  alias = "aws-us-east"
  region = "us-east-1"
}

provider "mongodbatlas" {
  alias = "mongo"
  username = "${var.mongodb_atlas_username}"
  api_key = "${var.mongodb_atlas_api_key}"

  # Matches any non-beta version >= 0.6.0 and < 0.7.0
  # Specifying a version is reommended for third-party providers
  version = "~> 0.6"
}

module "mongodb" {
  source = "./mongodb"

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