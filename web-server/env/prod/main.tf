/**
 * Infrastructure for the jarombek.com web server in the PROD environment
 * Author: Andrew Jarombek
 * Date: 3/22/2019
 */

locals {
  # Environment
  prod = true
  env = "${local.prod ? "prod" : "dev"}"

  # Port for load balancer to listen to on EC2 instances
  instance_port = 8080

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
    key = "jarombek-com-infrastructure/web-server/env/prod"
    region = "us-east-1"
  }
}

data "aws_security_group" "jarombek-com-mongodb-sg" {
  tags {
    Name = "jarombek-com-mongodb-security-${local.env}"
  }
}

module "server" {
  source = "../../modules/server"
  prod = "${local.prod}"
  instance_port = "${local.instance_port}"

  autoscaling_schedules = []

  launch-config-sg-rules-cidr = [
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
      # Connect to the instance from my IP
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${local.my_cidr}"
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

  launch-config-sg-rules-source = [
    {
      # Outbound traffic to the DocumentDB database
      type = "egress"
      from_port = 27017
      to_port = 27017
      protocol = "tcp"
      source_sg = "${data.aws_security_group.jarombek-com-mongodb-sg.id}"
    }
  ]

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
      # Connect to the instance from my IP
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${local.my_cidr}"
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

  load-balancer-sg-rules-source = [
    {
      # Outbound traffic to the DocumentDB database
      type = "egress"
      from_port = 27017
      to_port = 27017
      protocol = "tcp"
      source_sg = "${data.aws_security_group.jarombek-com-mongodb-sg.id}"
    }
  ]
}