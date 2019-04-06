/**
 * DocumentDB cluster on AWS for MongoDB
 * Author: Andrew Jarombek
 * Date: 3/20/2019
 */

locals {
  public_cidr = "0.0.0.0/0"
  my_cidr = "192.168.86.59/32"
  env = "${var.prod ? "prod" : "dev"}"
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

data "template_file" "public-key" {
  template = "${file("${path.module}/cred/jarombek_com_rsa.pub")}"
  vars {}
}

data "template_file" "private-key" {
  template = "${file("${path.module}/cred/jarombek_com_rsa")}"
  vars {}
}

#------------------------------
# JarombekCom MongoDB Resources
#------------------------------

resource "aws_cloudformation_stack" "jarombek-com-mongodb" {
  name = "jarombek-com-mongodb-${local.env}"
  template_body = "${file("${path.module}/mongodb.yml")}"
  on_failure = "DELETE"
  timeout_in_minutes = 20

  parameters {
    AMI = "${data.aws_ami.amazon-linux.id}"
    VpcId = "${data.aws_vpc.jarombek-com-vpc.id}"
    SubnetId = "${data.aws_subnet.jarombek-com-reputation-private-subnet.id}"
    MyCidr = "${local.my_cidr}"
    PublicCidr = "${local.public_cidr}"
    Env = "${local.env}"
    PublicKey = "${data.template_file.public-key.rendered}"
    PrivateKey = "${data.template_file.private-key.rendered}"
  }

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  tags {
    Name = "jarombek-com-mongodb-${local.env}"
    Application = "jarombek-com"
  }
}