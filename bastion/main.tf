/**
 * Infrastructure for creating a bastion host to private subnet resources
 * Author: Andrew Jarombek
 * Date: 3/21/2019
 */

locals {
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
    key = "jarombek-com-infrastructure/bastion"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_vpc" "jarombek-com-vpc" {
  tags {
    Name = "jarombekcom-vpc"
  }
}

data "aws_subnet" "jarombek-com-yandhi-public-subnet" {
  tags {
    Name = "jarombek-com-yandhi-public-subnet"
  }
}

data "aws_iam_role" "document-db-access-role" {
  name = "docdb-access-role"
}

data "template_file" "bastion-startup" {
  template = "${file("bastion-setup.sh")}"
}

#--------------------------------------
# Executed Before Resources are Created
#--------------------------------------

resource "null_resource" "bastion-key-gen" {
  provisioner "local-exec" {
    command = "bash key-gen.sh jarombek-com-bastion-key"
  }
}

#------------------------------
# New AWS Resources for Bastion
#------------------------------

/* EC2 instance for the bastion host.  It runs Amazon Linux 2 and can be accessed with bastion-key */
resource "aws_instance" "bastion" {
  # Use Amazon Linux 2
  ami = "ami-035be7bafff33b6b6"

  instance_type = "t2.micro"
  key_name = "jarombek-com-bastion-key"
  associate_public_ip_address = true

  subnet_id = "${data.aws_subnet.jarombek-com-yandhi-public-subnet.id}"
  security_groups = ["${module.bastion-subnet-security-group.security_group_id}"]
  iam_instance_profile = "${aws_iam_instance_profile.bastion-instance-profile.name}"

  lifecycle {
    create_before_destroy = true
  }

  user_data = "${data.template_file.bastion-startup.rendered}"

  tags {
    Name = "jarombek-com-bastion-host"
  }

  depends_on = ["null_resource.bastion-key-gen"]
}

/* The instance profile assigns the DocumentDB access IAM role to the bastion EC2 instance */
resource "aws_iam_instance_profile" "bastion-instance-profile" {
  name = "bastion-instance-profile"
  role = "${data.aws_iam_role.document-db-access-role.name}"
}

/* Security group rules for the Bastion EC2 instance.  Most important is SSH access for the AWS admin */
module "bastion-subnet-security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group"

  # Mandatory arguments
  name = "jarombek-com-bastion-security"
  tag_name = "jarombek-com-bastion-security"
  vpc_id = "${data.aws_vpc.jarombek-com-vpc.id}"

  # Optional arguments
  sg_rules = [
    {
      # Inbound traffic for SSH
      type = "ingress"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = "${local.my_cidr}"
    },
    {
      # Inbound traffic for ping
      type = "ingress"
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for HTTP
      type = "egress"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for HTTP
      type = "egress"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    },
    {
      # Outbound traffic for DocumentDB
      type = "egress"
      from_port = 27017
      to_port = 27017
      protocol = "tcp"
      cidr_blocks = "${local.public_cidr}"
    }
  ]

  description = "Allow SSH connections"
}