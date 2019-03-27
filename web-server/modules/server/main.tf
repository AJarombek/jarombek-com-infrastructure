/**
 * Infrastructure for the jarombek.com web server
 * Author: Andrew Jarombek
 * Date: 3/23/2019
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
  domain_cert = "${var.prod ? "jarombek.com" : "*.jarombek.com"}"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_vpc" "jarombekcom-vpc" {
  tags {
    Name = "jarombekcom-vpc"
  }
}

data "aws_subnet" "jarombek-com-yeezus-public-subnet" {
  tags {
    Name = "jarombek-com-yeezus-public-subnet"
  }
}

data "aws_subnet" "jarombek-com-yandhi-public-subnet" {
  tags {
    Name = "jarombek-com-yandhi-public-subnet"
  }
}

data "aws_ami" "jarombek-com-ami" {
  most_recent = true

  filter {
    name = "name"
    values = ["jarombek-com-${local.env}*"]
  }

  owners = ["739088120071"]
}

data "aws_acm_certificate" "jarombek-com-certificate" {
  domain = "${local.domain_cert}"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "jarombek-com-wildcard-certificate" {
  domain = "*.${local.domain_cert}"
  statuses = ["ISSUED"]
}

#--------------------------------------
# Executed Before Resources are Created
#--------------------------------------

resource "null_resource" "key-gen" {
  provisioner "local-exec" {
    command = "bash ../../modules/server/key-gen.sh ${var.prod ? "jarombek-com-key" : "jarombek-com-dev-key"}"
  }
}

#--------------------------------------------------
# New AWS Resources for the jarombek.com Web Server
#--------------------------------------------------

resource "aws_cloudformation_stack" "jarombek-com-server-cf-stack" {
  name = "jarombek-com-server-cf-stack"
  template_body = "${file("server.yml")}"
  on_failure = "DELETE"
  timeout_in_minutes = 20

  parameters {
    KeyName = "${var.prod ? "jarombek-com-key" : "jarombek-com-dev-key"}"
    SecurityGroupId = "${aws_security_group.jarombek-com-lc-security-group.id}"
    ImageId = "${data.aws_ami.jarombek-com-ami.id}"
    LCName = "jarombek-com-${local.env}-lc"
  }

  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]

  tags {
    Name = "jarombek-com-server-cf-stack"
  }

  depends_on = ["null_resource.key-gen"]
}

resource "aws_autoscaling_group" "jarombek-com-asg" {
  name = "jarombek-com-${local.env}-asg"
  launch_configuration = "${aws_cloudformation_stack.jarombek-com-server-cf-stack.outputs["LaunchConfigId"]}"
  vpc_zone_identifier = [
    "${data.aws_subnet.jarombek-com-yeezus-public-subnet.id}",
    "${data.aws_subnet.jarombek-com-yandhi-public-subnet.id}"
  ]

  max_size = "${var.max_size}"
  min_size = "${var.min_size}"
  desired_capacity = "${var.desired_capacity}"

  target_group_arns = [
    "${aws_lb_target_group.jarombek-com-lb-target-group.arn}",
    "${aws_lb_target_group.jarombek-com-lb-target-group-http.arn}"
  ]

  health_check_type = "ELB"
  health_check_grace_period = 600

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "jarombek-com-${local.env}-asg"
  }
}

resource "aws_autoscaling_schedule" "jarombek-com-asg-schedule" {
  count = "${length(var.autoscaling_schedules)}"

  autoscaling_group_name = "${aws_autoscaling_group.jarombek-com-asg.name}"
  scheduled_action_name = "${lookup(var.autoscaling_schedules[count.index], "name", "default-schedule")}"

  max_size = "${lookup(var.autoscaling_schedules[count.index], "max_size", 0)}"
  min_size = "${lookup(var.autoscaling_schedules[count.index], "min_size", 0)}"
  desired_capacity = "${lookup(var.autoscaling_schedules[count.index], "desired_capacity", 0)}"

  recurrence = "${lookup(var.autoscaling_schedules[count.index], "recurrence", "0 5 * * *")}"
}

resource "aws_lb" "jarombek-com-application-lb" {
  name = "jarombek-com-${local.env}-lb"
  load_balancer_type = "application"

  subnets = [
    "${data.aws_subnet.jarombek-com-yandhi-public-subnet.id}",
    "${data.aws_subnet.jarombek-com-yeezus-public-subnet.id}"
  ]

  security_groups = ["${aws_security_group.jarombek-com-lb-security-group.id}"]

  tags {
    Name = "jarombek-com-${local.env}-application-lb"
  }
}

resource "aws_lb_target_group" "jarombek-com-lb-target-group" {
  name = "jarombek-com-lb-target"

  health_check {
    interval = 10
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 2
    protocol = "HTTPS"
    path = "/"
    matcher = "200-299"
  }

  port = 443
  protocol = "HTTPS"
  vpc_id = "${data.aws_vpc.jarombekcom-vpc.id}"

  tags {
    Name = "jarombek-com-${local.env}-lb-target-group"
  }
}

resource "aws_lb_listener" "jarombek-com-lb-listener-https" {
  load_balancer_arn = "${aws_lb.jarombek-com-application-lb.arn}"
  port = 443
  protocol = "HTTPS"

  certificate_arn = "${data.aws_acm_certificate.jarombek-com-certificate.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.jarombek-com-lb-target-group.arn}"
    type = "forward"
  }
}

resource "aws_lb_listener_certificate" "jarombek-com-lb-listener-wc-cert" {
  listener_arn    = "${aws_lb_listener.jarombek-com-lb-listener-https.arn}"
  certificate_arn = "${data.aws_acm_certificate.jarombek-com-wildcard-certificate.arn}"
}

resource "aws_lb_target_group" "jarombek-com-lb-target-group-http" {
  name = "jarombek-com-lb-target-http"

  health_check {
    interval = 10
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 2
    protocol = "HTTP"
    path = "/"
    matcher = "200-299"
  }

  port = 80
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.jarombekcom-vpc.id}"

  tags {
    Name = "jarombek-com-${local.env}-lb-target-group-http"
  }
}

resource "aws_lb_listener" "jarombek-com-lb-listener-http" {
  load_balancer_arn = "${aws_lb.jarombek-com-application-lb.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.jarombek-com-lb-target-group-http.arn}"
    type = "forward"
  }
}

resource "aws_security_group" "jarombek-com-lc-security-group" {
  name = "jarombek-com-${local.env}-lc-security-group"
  vpc_id = "${data.aws_vpc.jarombekcom-vpc.id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "jarombek-com-${local.env}-lc-security-group"
  }
}

# You can't have both cidr_blocks and source_security_group_id in a security group rule.  Because of this limitation,
# the security group rules are separated into two resources.  One uses CIDR blocks, the other uses
# Source Security Groups.
resource "aws_security_group_rule" "jarombek-com-lc-security-group-rule-cidr" {
  count = "${length(var.launch-config-sg-rules-cidr)}"

  security_group_id = "${aws_security_group.jarombek-com-lc-security-group.id}"
  type = "${lookup(var.launch-config-sg-rules-cidr[count.index], "type", "ingress")}"

  from_port = "${lookup(var.launch-config-sg-rules-cidr[count.index], "from_port", 0)}"
  to_port = "${lookup(var.launch-config-sg-rules-cidr[count.index], "to_port", 0)}"
  protocol = "${lookup(var.launch-config-sg-rules-cidr[count.index], "protocol", "-1")}"

  cidr_blocks = ["${lookup(var.launch-config-sg-rules-cidr[count.index], "cidr_blocks", "")}"]
}

resource "aws_security_group_rule" "jarombek-com-lc-security-group-rule-source" {
  count = "${length(var.launch-config-sg-rules-source)}"

  security_group_id = "${aws_security_group.jarombek-com-lc-security-group.id}"
  type = "${lookup(var.launch-config-sg-rules-source[count.index], "type", "ingress")}"

  from_port = "${lookup(var.launch-config-sg-rules-source[count.index], "from_port", 0)}"
  to_port = "${lookup(var.launch-config-sg-rules-source[count.index], "to_port", 0)}"
  protocol = "${lookup(var.launch-config-sg-rules-source[count.index], "protocol", "-1")}"

  source_security_group_id = "${lookup(var.launch-config-sg-rules-source[count.index], "source_sg", "")}"
}

resource "aws_security_group" "jarombek-com-lb-security-group" {
  name = "jarombek-com-${local.env}-server-elb-security-group"
  vpc_id = "${data.aws_vpc.jarombekcom-vpc.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "jarombek-com-lb-security-group-rule-cidr" {
  count = "${length(var.load-balancer-sg-rules-cidr)}"

  security_group_id = "${aws_security_group.jarombek-com-lb-security-group.id}"
  type = "${lookup(var.load-balancer-sg-rules-cidr[count.index], "type", "ingress")}"

  from_port = "${lookup(var.load-balancer-sg-rules-cidr[count.index], "from_port", 0)}"
  to_port = "${lookup(var.load-balancer-sg-rules-cidr[count.index], "to_port", 0)}"
  protocol = "${lookup(var.load-balancer-sg-rules-cidr[count.index], "protocol", "-1")}"

  cidr_blocks = ["${lookup(var.load-balancer-sg-rules-cidr[count.index], "cidr_blocks", "")}"]
}

resource "aws_security_group_rule" "jarombek-com-lb-security-group-rule-source" {
  count = "${length(var.load-balancer-sg-rules-source)}"

  security_group_id = "${aws_security_group.jarombek-com-lb-security-group.id}"
  type = "${lookup(var.load-balancer-sg-rules-source[count.index], "type", "ingress")}"

  from_port = "${lookup(var.load-balancer-sg-rules-source[count.index], "from_port", 0)}"
  to_port = "${lookup(var.load-balancer-sg-rules-source[count.index], "to_port", 0)}"
  protocol = "${lookup(var.load-balancer-sg-rules-source[count.index], "protocol", "-1")}"

  source_security_group_id = "${lookup(var.load-balancer-sg-rules-source[count.index], "source_sg", "")}"
}