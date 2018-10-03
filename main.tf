/**
 * Author: Andrew Jarombek
 * Date: 9/7/2018
 */

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "vpc"
}

module "s3-tfstate" {
  source = "s3-tfstate"
}

module "route53" {
  source = "route53"

  ip = "18.188.35.236"
}

module "ec2-web" {
  source = "ec2-web"
}

module "ec2-mongodb" {
  source = "ec2-mongodb"
}

module "s3-assets" {
  source = "s3-assets"
}