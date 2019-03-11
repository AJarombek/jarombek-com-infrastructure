/**
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

variable "provider_name" {
  description = "Name of the cloud provider to host the MongoDB database"
  default = "AWS"
}

variable "region" {
  description = "The region to contain the MongoDB cluster"
  default = "US-EAST-1"
}

variable "cidr_whitelist" {
  description = "The CIDR block for whitelisted IPs to access the database"
  default = "0.0.0.0/24"
}

variable "database_user_andy_password" {
  description = "The password user 'andy' in MongoDB"
}