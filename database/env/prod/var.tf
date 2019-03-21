/**
 * Variables for the PROD database module
 * Author: Andrew Jarombek
 * Date: 3/20/2019
 */

variable "username" {
  description = "Master username for the database"
  type = "string"
}

variable "password" {
  description = "Master password for the database"
  type = "string"
}