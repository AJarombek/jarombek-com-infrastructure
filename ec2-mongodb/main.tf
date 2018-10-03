/**
 * EC2 instances for MongoDB
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

resource "aws_instance" "mongodb" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = ["${var.security_group_id}"]
  subnet_id = "${var.subnet_id}"
  source_dest_check = false

  tags {
    Name = "jarombek-com-mongodb"
  }
}