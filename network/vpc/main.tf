/**
 * Set up a Virtual Private Cloud for jarombek.com
 * Author: Andrew Jarombek
 * Date: 10/2/2018
 */

data "aws_availability_zones" "all" {}

resource "aws_vpc" "jarombek-com-vpc" {
  cidr_block = "${var.vpc_cidr}"

  # This is needed for VPC peering to work (ex. with MongoDB Atlas)
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

resource "aws_subnet" "private-subnet" {
  cidr_block = "${var.private_subnet_cidr}"
  vpc_id = "${aws_vpc.jarombek-com-vpc.id}"
  availability_zone = "${data.aws_availability_zones.all[1]}"

  tags {
    Name = "Private Subnet"
  }
}

# Allows the public subnet to be addressable from the internet
resource "aws_internet_gateway" "jarombek-igw" {
  vpc_id = "${aws_vpc.jarombek-com-vpc.id}"

  tags {
    Name = "VPC Internet Gateway"
  }
}

# Define a routing table that enables traffic from the public subnet to the internet
resource "aws_route_table" "jarombek-routing-table" {
  vpc_id = "${aws_vpc.jarombek-com-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.jarombek-igw.id}"
  }

  tags {
    Name = "Public Subnet RT"
  }
}

# Connect the routing table to the public subnet
resource "aws_route_table_association" "jarombek-routing-table-association" {
  route_table_id = "${aws_route_table.jarombek-routing-table.id}"
  subnet_id = "${aws_subnet.public-subnet.id}"
}

resource "aws_security_group" "public-subnet-security" {
  name = "jarombek-vpc-public-security"
  description = "Allow all incoming connections to public resources"
  vpc_id = "${aws_vpc.jarombek-com-vpc.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP is used for sending error messages or operational information.  ICMP has no ports,
  # and a common tool that uses ICMP is ping.
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Public Subnet Security"
  }
}

resource "aws_security_group" "private-subnet-security" {
  name = "jarombek-vpc-private-security"
  description = "Allow traffic only from the public subnet"
  vpc_id = "${aws_vpc.jarombek-com-vpc.id}"

  ingress {
    # Default port for MongoDB
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    # Ports MongoDB uses to communicate between servers
    from_port = 27019
    to_port = 27019
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  tags {
    Name = "Private Subnet Security"
  }
}