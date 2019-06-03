/**
 * ALB for an ECS cluster
 * Author: Andrew Jarombek
 * Date: 4/13/2019
 */

locals {
  env = var.prod ? "prod" : "dev"
  env_tag = var.prod ? "production" : "development"
  domain_cert = var.prod ? "jarombek.com" : "*.jarombek.com"
  wildcard_domain_cert = var.prod ? "*.jarombek.com" : "*.dev.jarombek.com"
  web_domain = var.prod ? "jarombek.com." : "dev.jarombek.com."
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_vpc" "jarombek-com-vpc" {
  tags = {
    Name = "jarombek-com-vpc"
  }
}

data "aws_subnet" "jarombek-com-yeezus-public-subnet" {
  tags = {
    Name = "jarombek-com-yeezus-public-subnet"
  }
}

data "aws_subnet" "jarombek-com-yandhi-public-subnet" {
  tags = {
    Name = "jarombek-com-yandhi-public-subnet"
  }
}

data "aws_acm_certificate" "jarombek-com-certificate" {
  domain = local.domain_cert
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "jarombek-com-wildcard-certificate" {
  domain = local.wildcard_domain_cert
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "jarombek" {
  name = "jarombek.com."
}

#--------------
# ALB Resources
#--------------

resource "aws_lb" "jarombek-com-lb" {
  name = "jarombek-com-${local.env}-alb"

  subnets = [
    data.aws_subnet.jarombek-com-yandhi-public-subnet.id,
    data.aws_subnet.jarombek-com-yeezus-public-subnet.id
  ]

  security_groups = [aws_security_group.jarombek-com-lb-security-group.id]

  tags = {
    Name = "jarombek-com-${local.env}-alb"
    Application = "jarombek-com"
    Environment = local.env_tag
  }
}

resource "aws_lb_target_group" "jarombek-com-lb-target-group" {
  name = "jarombek-com-${local.env}-lb-target"

  health_check {
    enabled = true
    interval = 10
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 2
    port = 8080
    protocol = "HTTP"
    path = "/"
    matcher = "200-299"
  }

  port = 8080
  protocol = "HTTP"
  vpc_id = data.aws_vpc.jarombek-com-vpc.id
  target_type = "ip"

  tags = {
    Name = "jarombek-com-${local.env}-lb-target-group"
    Application = "jarombek-com"
    Environment = local.env_tag
  }
}

resource "aws_lb_listener" "jarombek-com-lb-listener-https" {
  load_balancer_arn = aws_lb.jarombek-com-lb.arn
  port = 443
  protocol = "HTTPS"

  certificate_arn = data.aws_acm_certificate.jarombek-com-certificate.arn

  default_action {
    target_group_arn = aws_lb_target_group.jarombek-com-lb-target-group.arn
    type = "forward"
  }
}

resource "aws_lb_listener_certificate" "jarombek-com-lb-listener-wc-cert" {
  listener_arn    = aws_lb_listener.jarombek-com-lb-listener-https.arn
  certificate_arn = data.aws_acm_certificate.jarombek-com-wildcard-certificate.arn
}

resource "aws_lb_listener" "jarombek-com-lb-listener-http" {
  load_balancer_arn = aws_lb.jarombek-com-lb.arn
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
  name = "jarombek-com-${local.env}-lb-security-group"
  vpc_id = data.aws_vpc.jarombek-com-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "jarombek-com-${local.env}-lb-security-group"
    Application = "jarombek-com"
    Environment = local.env_tag
  }
}

resource "aws_security_group_rule" "jarombek-com-lb-security-group-rule-cidr" {
  count = length(var.load-balancer-sg-rules-cidr)

  security_group_id = aws_security_group.jarombek-com-lb-security-group.id
  type = lookup(var.load-balancer-sg-rules-cidr[count.index], "type", "ingress")

  from_port = lookup(var.load-balancer-sg-rules-cidr[count.index], "from_port", 0)
  to_port = lookup(var.load-balancer-sg-rules-cidr[count.index], "to_port", 0)
  protocol = lookup(var.load-balancer-sg-rules-cidr[count.index], "protocol", "-1")

  cidr_blocks = [lookup(var.load-balancer-sg-rules-cidr[count.index], "cidr_blocks", "")]
}

resource "aws_security_group_rule" "jarombek-com-lb-security-group-rule-source" {
  count = length(var.load-balancer-sg-rules-source)

  security_group_id = aws_security_group.jarombek-com-lb-security-group.id
  type = lookup(var.load-balancer-sg-rules-source[count.index], "type", "ingress")

  from_port = lookup(var.load-balancer-sg-rules-source[count.index], "from_port", 0)
  to_port = lookup(var.load-balancer-sg-rules-source[count.index], "to_port", 0)
  protocol = lookup(var.load-balancer-sg-rules-source[count.index], "protocol", "-1")

  source_security_group_id = lookup(var.load-balancer-sg-rules-source[count.index], "source_sg", "")
}

#--------------
# DNS Resources
#--------------

resource "aws_route53_record" "jarombek_a" {
  name = local.web_domain
  type = "A"
  zone_id = data.aws_route53_zone.jarombek.zone_id

  alias {
    evaluate_target_health = true
    name = aws_lb.jarombek-com-lb.dns_name
    zone_id = aws_lb.jarombek-com-lb.zone_id
  }
}

resource "aws_route53_record" "jarombek_cname" {
  name = "www.${local.web_domain}"
  type = "CNAME"
  zone_id = data.aws_route53_zone.jarombek.zone_id
  ttl = 300

  records = [local.web_domain]
}

#--------------------
# Module Dependencies
#--------------------

/*
  Dependencies required by resources in other modules.  Based of the following design:
  https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
*/
resource "null_resource" "dependency-setter" {
  depends_on = [
    aws_lb.jarombek-com-lb,
    aws_lb_listener.jarombek-com-lb-listener-http,
    aws_lb_listener.jarombek-com-lb-listener-https,
    aws_lb_listener_certificate.jarombek-com-lb-listener-wc-cert,
    aws_lb_target_group.jarombek-com-lb-target-group
  ]
}