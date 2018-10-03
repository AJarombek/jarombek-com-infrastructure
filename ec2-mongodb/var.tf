/**
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

variable "ami" {
  description = "The Amazon Machine Image for the instance"
  default = "ami-04169656fea786776"
}

variable "security_group_id" {
  description = "The id of the AWS security group for the mongodb server"
}

variable "instance_type" {
  description = "The instance type (size of the instance)"
  default = "t2.small"
}

variable "subnet_id" {
  description = "The Subnet that the EC2 instance will exist in"
}