/**
 * Infrastructure for jarombek.com Ingress to Kubernetes in the development environment
 * Author: Andrew Jarombek
 * Date: 10/1/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 1.3.9"

  required_providers {
    aws        = "~> 4.61.0"
    kubernetes = "~> 2.19.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "jarombek-com-infrastructure/jarombek-com-kubernetes-ingress/env/prod"
    region  = "us-east-1"
  }
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  prod   = true
}