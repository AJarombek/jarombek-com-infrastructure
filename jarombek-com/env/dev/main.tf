/**
 * Infrastructure for the jarombek.com ECS cluser in the DEV environment
 * Author: Andrew Jarombek
 * Date: 4/18/2019
 */

locals {
  # Environment
  prod = false
  env = "${local.prod ? "prod" : "dev"}"

  # CIDR blocks for firewalls
  public_cidr = "0.0.0.0/0"
  my_cidr = "69.124.72.192/32"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/jarombek-com/env/dev"
    region = "us-east-1"
  }
}

module "alb" {
  source = "../../modules/alb"
  prod = "${local.prod}"

  load-balancer-sg-rules-cidr = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for health checks
      type = "egress"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic to the internet
      type = "egress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic to the internet
      type = "egress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    }
  ]

  load-balancer-sg-rules-source = []
}

module "ecs" {
  source = "../../modules/ecs"
  prod = "${local.prod}"
  jarombek_com_desired_count = 1
  jarombek_com_database_desired_count = 1
  alb_security_group = "${module.alb.alb-sg}"
}