/**
 * Author: Andrew Jarombek
 * Date: 10/2/2018
 */

variable "vpc_cidr" {
  description = "The CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR for the public subnet"
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "The CIDR for the private subnet"
  default = "10.0.2.0/24"
}