/**
 * Set up a Virtual Private Cloud for jarombek.com
 * Author: Andrew Jarombek
 * Date: 10/2/2018
 */

data "aws_availability_zones" "all" {}

resource "aws_vpc" "jarombek-com-vpc" {
  cidr_block = "${var.vpc_cidr}"

  enable_dns_hostnames = true

  tags {
    Name = "jarombek-com-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  cidr_block = "${var.public_subnet_cidr}"
  vpc_id = "${aws_vpc.jarombek-com-vpc.id}"
  availability_zone = "${data.aws_availability_zones.all[0]}"

  tags {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "${var.private_subnet_cidr}"
  vpc_id = "${aws_vpc.jarombek-com-vpc.id}"
  availability_zone = "${data.aws_availability_zones.all[1]}"

  tags {
    Name = "Private Subnet"
  }
}