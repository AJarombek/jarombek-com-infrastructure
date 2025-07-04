/**
 * Infrastructure for jarombek.com on Kubernetes in the production environment
 * Author: Andrew Jarombek
 * Date: 9/25/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.6.6"

  required_providers {
    aws        = "~> 4.61.0"
    kubernetes = "~> 2.19.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "jarombek-com-infrastructure/jarombek-com-kubernetes/env/prod"
    region  = "us-east-1"
  }
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  prod   = true
}