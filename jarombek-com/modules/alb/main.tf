/**
 * ALB for an ECS cluster
 * Author: Andrew Jarombek
 * Date: 4/13/2019
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
  env_tag = "${var.prod ? "production" : "development"}"
  domain_cert = "${var.prod ? "jarombek.io" : "*.jarombek.io"}"
  wildcard_domain_cert = "${var.prod ? "*.jarombek.io" : "*.dev.jarombek.io"}"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_vpc" "jarombek-com-vpc" {
  tags {
    Name = "jarombek-com-vpc"
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

data "aws_acm_certificate" "jarombek-com-certificate" {
  domain = "${local.domain_cert}"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "jarombek-com-wildcard-certificate" {
  domain = "${local.wildcard_domain_cert}"
  statuses = ["ISSUED"]
}

#--------------
# ALB Resources
#--------------

resource "aws_alb" "jarombek-com-alb" {
  name = "jarombek-com-${local.env}-alb"

  subnets = [
    "${data.aws_subnet.jarombek-com-yandhi-public-subnet.id}",
    "${data.aws_subnet.jarombek-com-yeezus-public-subnet.id}"
  ]

  security_groups = ["${aws_security_group.jarombek-com-lb-security-group.id}"]

  tags {
    Name = "jarombek-com-${local.env}-alb"
    Application = "jarombek-com"
    Environment = "${local.env_tag}"
  }
}

resource "aws_lb_target_group" "jarombek-com-lb-target-group" {
  name = "jarombek-com-alb-target"

  health_check {
    interval = 10
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 2
    port = "traffic-port"
    protocol = "HTTPS"
    path = "/"
    matcher = "200-299"
  }

  port = 443
  protocol = "HTTPS"
  vpc_id = "${data.aws_vpc.jarombek-com-vpc.id}"
  target_type = "ip"

  tags {
    Name = "jarombek-com-${local.env}-lb-target-group"
    Application = "jarombek-com"
    Environment = "${local.env_tag}"
  }
}

resource "aws_lb_listener" "jarombek-com-lb-listener-https" {
  load_balancer_arn = "${aws_alb.jarombek-com-alb.arn}"
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

resource "aws_lb_listener" "jarombek-com-lb-listener-http" {
  load_balancer_arn = "${aws_alb.jarombek-com-alb.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_security_group" "jarombek-com-lb-security-group" {
  name = "jarombek-com-${local.env}-alb-security-group"
  vpc_id = "${data.aws_vpc.jarombek-com-vpc.id}"

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

/*
  Dependencies required by resources in other modules.  Based of the following design:
  https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
*/
resource "null_resource" "dependency-setter" {
  depends_on = [
    "aws_alb.jarombek-com-alb",
    "aws_lb_listener.jarombek-com-lb-listener-http",
    "aws_lb_listener.jarombek-com-lb-listener-https",
    "aws_lb_listener_certificate.jarombek-com-lb-listener-wc-cert",
    "aws_lb_target_group.jarombek-com-lb-target-group",
    "aws_lb_target_group.jarombek-com-lb-target-group-http"
  ]
}