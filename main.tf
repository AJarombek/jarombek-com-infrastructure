/**
 * Author: Andrew Jarombek
 * Date: 9/7/2018
 */

provider "aws" {
  region = "us-east-1"
}

module "route53" {
  source = "route53"

  ip = "18.188.35.236"
}

module "s3-assets" {
  source = "s3-assets"
}