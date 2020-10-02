/**
 * Variables for the jarombek.com Kubernetes Ingress.
 * Author: Andrew Jarombek
 * Date: 10/1/2020
 */

variable "prod" {
  description = "If the environment for the jarombek.com Kubernetes Ingress is production"
  default = false
}