/**
 * Configure the EC2 instance for the web server
 * Author: Andrew Jarombek
 * Date: 10/1/2018
 */

# Fetch the availability zones for this AWS account
# Each time terraform runs, the availability zones will be fetched from the AWS provider
data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "jaromek-com" {
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.jarombek-com-security.id}"]

  user_data = ""

  lifecycle {
    # Always create a replacement resource before destroying an original resource
    create_before_destroy = true
  }
}

resource "aws_security_group" "jarombek-com-security" {
  name = "jarombek-com"

  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Lifecycle must be specified here since it was added to aws_launch_configuration (pg. 50)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "jarombek-com-asg" {
  launch_configuration = "${aws_launch_configuration.jaromek-com.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  max_size = "${var.max_size}"
  min_size = "${var.min_size}"

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "jarombek-com-asg"
  }
}

resource "aws_elb" "jarombek-com-elb" {
  name = "jarombek-com-elb"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups = ["${aws_security_group.jarombek-com-elb-security.id}"]

  listener {
    # Port and protocol to receive requests on the load balancer
    lb_port = 80
    lb_protocol = "http"

    # Port and protocol to route requests to the EC2 instances
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }
}

# Additional security group for the elastic load balancer
resource "aws_security_group" "jarombek-com-elb-security" {
  name = "jarombek-com-elb-security"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}