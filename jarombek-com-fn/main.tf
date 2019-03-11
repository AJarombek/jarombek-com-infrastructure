/**
 * Author: Andrew Jarombek
 * Date: 10/6/2018
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
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

module "lamda" {
  source = "./lambda"
}

module "api-gateway" {
  source = "./api-gateway"

  lambda-function-name = "${module.lamda.lambda_function_name}"
}