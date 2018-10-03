/**
 * Author: Andrew Jarombek
 * Date: 10/3/2018
 */

output "ami" {
  value = "${data.aws_ami.linux-latest.image_id}"
}