/**
 * Variables for the ECS cluster
 * Author: Andrew Jarombek
 * Date: 4/13/2019
 */

variable "dependencies" {
  description = "Resources that this module is dependent on"
  type = list
}

variable "prod" {
  description = "If the environment for the ECS cluster is production"
  default = false
}

variable "jarombek_com_desired_count" {
  description = "The desired number of jarombek-com task instances to run in the ECS cluster"
  default = 1
}

variable "jarombek_com_database_desired_count" {
  description = "The desired number of jarombek-com-database task instances to run in the ECS cluster"
  default = 1
}

variable "alb_security_group" {
  description = "Security group for the ALB used by the ECS cluster"
}

variable "jarombek-com-lb-target-group" {
  description = "Target Group for the jarombek-com Load Balancer"
}