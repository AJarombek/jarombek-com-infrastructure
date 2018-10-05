/**
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

variable "provider_name" {
  description = "Name of the cloud provider to host the MongoDB database"
  default = "AWS"
}

variable "aws_region" {
  description = "The AWS region to contain the MongoDB cluster"
  default = "US-EAST-1"
}

variable "aws_account_id" {
  description = "The ID of the AWS account"
}

variable "aws_vpc_id" {
  description = "The ID of the VPC on AWS to peer with the MongoDB cluster"
}

variable "aws_vpc_cidr_block" {
  description = "The CIDR block of the AWS VPC"
}

variable "database_user_andy_password" {
  description = "The password user 'andy' in MongoDB"
}