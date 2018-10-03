/**
 * Author: Andrew Jarombek
 * Date: 9/6/2018
 */

output "route_53_record_count" {
  value = "${aws_route53_zone.jarombek.count}"
}