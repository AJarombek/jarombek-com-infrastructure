/**
 * Author: Andrew Jarombek
 * Date: 10/6/2018
 */

provider "aws" {
  region = "us-east-1"
}

module "lamda" {
  source = "./lambda"
}

module "api-gateway" {
  source = "./api-gateway"

  lambda-function-name = "${module.lamda.lambda_function_name}"
}

module "s3-tfstate" {
  source = "./s3-tfstate"
}