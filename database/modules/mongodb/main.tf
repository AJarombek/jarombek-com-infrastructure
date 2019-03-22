/**
 * DocumentDB cluster on AWS for MongoDB
 * Author: Andrew Jarombek
 * Date: 3/20/2019
 */

locals {
  public_cidr = "0.0.0.0/0"
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

data "aws_subnet" "jarombek-com-red-private-subnet" {
  tags {
    Name = "jarombek-com-red-private-subnet"
  }
}

#---------------------------------
# JarombekCom DocumentDB Resources
#---------------------------------

resource "aws_docdb_cluster" "mongodb-cluster" {
  cluster_identifier = "jarombek-com-docdb-cluster"
  engine = "docdb"
  master_username = "${var.username}"
  master_password = "${var.password}"
  port = 27017
  backup_retention_period = 3
  preferred_backup_window = "05:00-07:00"
  skip_final_snapshot = true

  vpc_security_group_ids = ["${module.jarombek-com-mongodb-security-group.security_group_id[0]}"]
  db_subnet_group_name = "${aws_docdb_subnet_group.mongodb-cluster-subnet-group.id}"
}

resource "aws_docdb_instance" "mongodb-cluster-instances" {
  count = 2
  identifier = "jarombek-com-docdb-instance-${count.index}"
  cluster_identifier = "${aws_docdb_cluster.mongodb-cluster.id}"
  instance_class = "db.t2.micro"
}

resource "aws_docdb_subnet_group" "mongodb-cluster-subnet-group" {
  name = "jarombek-com-docdb-subnet-group"
  subnet_ids = [
    "${data.aws_subnet.jarombek-com-red-private-subnet.id}",
    "${data.aws_subnet.jarombek-com-reputation-private-subnet.id}"
  ]

  tags = {
    Name = "jarombek-com-docdb-subnet-group"
  }
}

module "jarombek-com-mongodb-security-group" {
  source = "github.com/ajarombek/terraform-modules//security-group?ref=v0.1.0"

  # Mandatory arguments
  name = "jarombek-com-mongodb-security"
  tag_name = "jarombek-com-mongodb-security"
  vpc_id = "${data.aws_vpc.jarombek-com-vpc.id}"

  # Optional arguments
  sg_rules = "${local.jarombekcom_mongodb_sg_rules}"
  description = "Allow incoming connections on the default MongoDB port"
}