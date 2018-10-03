/**
 * Author: Andrew Jarombek
 * Date: 10/1/2018
 */

variable "server_port" {
  description = "The port for the web server"
  default = 8080
}

variable "instance_type" {
  description = "The instance type (size of the instance)"
  default = "t2.small"
}

variable "ami" {
  description = "The Amazon Machine Image for the instance"
  default = "ami-04169656fea786776"
}

variable "max_size" {
  description = "Max number of instances in the auto scaling group"
  default = 6
}

variable "min_size" {
  description = "Min number of instances in the auto scaling group"
  default = 2
}