/**
 * Infrastructure for the jarombek.com ECS cluser in the PROD environment
 * Author: Andrew Jarombek
 * Date: 4/18/2019
 */

locals {
  # Environment
  prod = true
  env = local.prod ? "prod" : "dev"

  # CIDR blocks for firewalls
  public_cidr = "0.0.0.0/0"
  my_cidr = "69.124.72.192/32"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/jarombek-com/env/prod"
    region = "us-east-1"
  }
}

module "alb" {
  source = "../../modules/alb"
  prod = local.prod

  load-balancer-sg-rules-cidr = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = local.public_cidr
    },
    {
      # Outbound traffic on all ports
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = local.public_cidr
    }
  ]

  load-balancer-sg-rules-source = []
}

module "ecs" {
  source = "../../modules/ecs"
  prod = local.prod
  jarombek_com_desired_count = 1
  jarombek_com_database_desired_count = 1
  alb_security_group = module.alb.alb-sg
  jarombek-com-lb-target-group = module.alb.jarombek-com-lb-target-group

  dependencies = [
    module.alb.depended_on
  ]
}