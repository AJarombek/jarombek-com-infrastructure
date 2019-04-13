/**
 * Variables for the ECS cluster
 * Author: Andrew Jarombek
 * Date: 4/13/2019
 */

variable "prod" {
  description = "If the environment for the ECS cluster is production"
  default = false
}

variable "desired_count" {
  description = "The desired number of tasks to run in the ECS cluster"
  default = 1
}