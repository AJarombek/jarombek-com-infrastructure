/**
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

provider "aws" {
  region = "us-east-1"
}

# Retrieve the VPC from AWS
data "aws_subnet" "jarombek-com-public-subnet" {
  tags {
    Name = "Public Subnet"
  }
}

data "aws_security_group" "jarombek-com-public-subnet-security" {
  tags {
    Name = "Public Subnet Security"
  }
}

module "s3-tfstate" {
  source = "./s3-tfstate"
}

module "ami" {
  source = "./ami"
}

module "ec2-web" {
  source = "services\/ec2-web"

  security_group_id = "${data.aws_security_group.jarombek-com-public-subnet-security.id}"
  ami = "${module.ami.ami}"
  subnet_id = "${data.aws_subnet.jarombek-com-public-subnet.id}"
}