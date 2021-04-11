/**
 * Infrastructure for jarombek.com on Kubernetes in the production environment
 * Author: Andrew Jarombek
 * Date: 9/25/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = ">= 3.7.0"
    kubernetes = ">= 2.0.3"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/jarombek-com-kubernetes/env/prod"
    region = "us-east-1"
  }
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  prod = true
}