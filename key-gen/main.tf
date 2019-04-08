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

resource "null_resource" "git-key-gen" {
  provisioner "local-exec" {
    command = "bash git-key-gen.sh jarombek_com_rsa"
  }
}

resource "null_resource" "ec2-key-gen" {
  provisioner "local-exec" {
    command = "bash ec2-key-gen.sh jarombek-com-key"
  }
}