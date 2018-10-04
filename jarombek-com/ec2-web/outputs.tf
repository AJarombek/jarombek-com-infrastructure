/**
 * Author: Andrew Jarombek
 * Date: 10/1/2018
 */

output "elb_dns_name" {
  value = "${aws_elb.jarombek-com-elb.dns_name}"
}