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
}

module "s3-tfstate" {
  source = "./s3-tfstate"
}