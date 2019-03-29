/**
 * Author: Andrew Jarombek
 * Date: 3/28/2019
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

module "lambda" {
  source = "./lambda"
}

module "api-gateway" {
  source = "./api-gateway"
  lambda-function-name = "${module.lambda.function-name}"
}