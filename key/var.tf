/**
 * Variables for creating SSH keys
 * Author: Andrew Jarombek
 * Date: 4/5/2019
 */

variable "key-names" {
  description = "The name of the SSH keys"
  type = "list"
  default = ["jarombek-com-mongodb-key"]
}