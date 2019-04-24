/**
 * The websites ECS cluster
 * Author: Andrew Jarombek
 * Date: 4/13/2019
 */

locals {
  env = "${var.prod ? "prod" : "dev"}"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_vpc" "jarombek-com-vpc" {
  tags {
    Name = "jarombek-com-vpc"
  }
}

#---------------------
# ECS Cluser Resources
#---------------------

resource "aws_ecs_cluster" "jarombek-com-ecs-cluster" {
  name = "jarombek-com-ecs-cluster"
}

resource "aws_ecs_task_definition" "jarombek-com-task" {
  family = "jarombek-com"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512

  container_definitions = "${file("${path.module}/container-def.json")}"
}

resource "aws_ecs_service" "jarombek-com-service" {
  name = "jarombek-com-ecs-service"
  cluster = "${aws_ecs_cluster.jarombek-com-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.jarombek-com-task.arn}"
  desired_count = "${var.desired_count}"
  launch_type = "FARGATE"
}

resource "aws_security_group" "jarombek-com-ecs-sg" {
  name = "jarombek-com-${local.env}-ecs-security-group"
  vpc_id = "${data.aws_vpc.jarombek-com-vpc.id}"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    security_groups = ["${var.alb_security_group}"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 80
    security_groups = ["${var.alb_security_group}"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}