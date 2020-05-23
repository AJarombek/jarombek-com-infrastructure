/**
 * Author: Andrew Jarombek
 * Date: 3/28/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/jarombek-com-fn"
    region = "us-east-1"
  }
}

#------------------
# Terraform Modules
#------------------

module "lambda" {
  source = "./lambda"
}

module "api-gateway" {
  source = "./api-gateway"
  lambda-function-name = "${module.lambda.function-name}"
}