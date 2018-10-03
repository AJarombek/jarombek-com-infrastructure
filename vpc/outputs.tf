/**
 * Author: Andrew Jarombek
 * Date: 10/2/2018
 */

output "public-subnet-id" {
  value = "${aws_subnet.public-subnet.id}"
}

output "public-subnet-security-group-id" {
  value = "${aws_security_group.public-subnet-security.id}"
}

output "private-subnet-id" {
  value = "${aws_subnet.private-subnet.id}"
}

output "private-subnet-security-group-id" {
  value = "${aws_security_group.private-subnet-security.id}"
}