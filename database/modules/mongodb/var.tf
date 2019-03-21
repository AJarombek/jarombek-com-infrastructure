/**
 * Variables for the MongoDB database
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

variable "prod" {
  description = "If the environment that mongodb lives in is production"
  default = false
}

variable "username" {
  description = "Master username for the database"
  type = "string"
}

variable "password" {
  description = "Master password for the database"
  type = "string"
}