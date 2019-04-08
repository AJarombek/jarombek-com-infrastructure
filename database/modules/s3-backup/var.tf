/**
 * Variables for the S3 bucket containing MongoDB backups
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

variable "expiration_days" {
  description = "Days until an object in the S3 bucket expires and is deleted"
  default = 14
}

variable "prod" {
  description = "If the environment that mongodb lives in is production"
  default = false
}