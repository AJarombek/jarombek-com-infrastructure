/*
 * Create SSH keys for connecting to EC2 instances
 * Author: Andrew Jarombek
 * Date: 4/5/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/key"
    region = "us-east-1"
  }
}

resource "null_resource" "key-gen" {
  count = "${length(var.key-names)}"
  provisioner "local-exec" {
    command = "bash key-gen.sh ${var.key-names[count.index]}"
  }
}