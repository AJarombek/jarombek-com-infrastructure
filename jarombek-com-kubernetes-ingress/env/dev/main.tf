/**
 * Infrastructure for jarombek.com Ingress to Kubernetes in the development environment
 * Author: Andrew Jarombek
 * Date: 10/1/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.14"

  required_providers {
    aws        = ">= 3.7.0"
    kubernetes = ">= 1.11"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "jarombek-com-infrastructure/jarombek-com-kubernetes-ingress/env/dev"
    region  = "us-east-1"
  }
}

module "kubernetes" {
  source = "../../modules/kubernetes"
  prod   = false
}