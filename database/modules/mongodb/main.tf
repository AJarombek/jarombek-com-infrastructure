/**
 * DocumentDB cluster on AWS for MongoDB
 * Author: Andrew Jarombek
 * Date: 3/20/2019
 */

locals {
  public_cidr = "0.0.0.0/0"
  my_cidr = "69.124.72.192/32"
  env = "${var.prod ? "prod" : "dev"}"
  jarombekcom_mongodb_sg_rules = [
    {
      # Inbound traffic from the internet
      type = "ingress"
      from_port = 27017
      to_port = 27017
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    }
  ]
}

#-----------------------------------
# Existing JarombekCom VPC Resources
#-----------------------------------

data "aws_vpc" "jarombek-com-vpc" {
  tags {
    Name = "jarombekcom-vpc"
  }
}

data "aws_subnet" "jarombek-com-reputation-private-subnet" {
  tags {
    Name = "jarombek-com-reputation-private-subnet"
  }
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners = ["137112412989"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

#---------------------------------
# JarombekCom DocumentDB Resources
#---------------------------------

resource "aws_cloudformation_stack" "jarombek-com-mongodb" {
  name = "jarombek-com-mongodb"
  template_body = "${file("mongodb.yml")}"
  on_failure = "DELETE"
  timeout_in_minutes = 20

  parameters {
    VpcId = "${data.aws_vpc.jarombek-com-vpc.id}"
    SubnetId = "${data.aws_subnet.jarombek-com-reputation-private-subnet.id}"
  }

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  tags {
    Name = "jarombek-com-mongodb"
  }
}

module "jarombek-com-mongodb-security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group?ref=v0.1.0"

  # Mandatory arguments
  name = "jarombek-com-mongodb-security-${local.env}"
  tag_name = "jarombek-com-mongodb-security-${local.env}"
  vpc_id = "${data.aws_vpc.jarombek-com-vpc.id}"

  # Optional arguments
  sg_rules = "${local.jarombekcom_mongodb_sg_rules}"
  description = "Allow incoming connections on the default MongoDB port"
}