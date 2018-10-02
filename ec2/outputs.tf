/**
 * Author: Andrew Jarombek
 * Date: 10/1/2018
 */

output "public_ip" {
  value = "${.jaromek-com.public_ip}"
}

output "elastic_ip" {
  value = "${aws_eip.jarombek-com-ip.public_ip}"
}