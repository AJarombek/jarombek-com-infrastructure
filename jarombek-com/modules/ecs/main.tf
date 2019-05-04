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

data "aws_iam_role" "ecs-task-role" {
  name = "ecs-task-role"
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
  execution_role_arn = "${data.aws_iam_role.ecs-task-role.arn}"
  cpu = 256
  memory = 512

  container_definitions = "${file("${path.module}/container-def/jarombek-com.json")}"
}

resource "aws_ecs_service" "jarombek-com-service" {
  name = "jarombek-com-ecs-service"
  cluster = "${aws_ecs_cluster.jarombek-com-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.jarombek-com-task.arn}"
  desired_count = "${var.jarombek_com_desired_count}"
  launch_type = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.jarombek-com-ecs-sg.id}"]
    subnets = [
      "${data.aws_subnet.jarombek-com-yeezus-public-subnet.id}",
      "${data.aws_subnet.jarombek-com-yandhi-public-subnet.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${var.jarombek-com-lb-target-group}"
    container_name = "jarombek-com"
    container_port = 8080
  }
}

resource "aws_ecs_task_definition" "jarombek-com-database-task" {
  family = "jarombek-com-database"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = "${data.aws_iam_role.ecs-task-role.arn}"
  cpu = 256
  memory = 512

  container_definitions = "${file("${path.module}/container-def/jarombek-com-database.json")}"
}

resource "aws_ecs_service" "jarombek-com-database-service" {
  name = "jarombek-com-database-ecs-service"
  cluster = "${aws_ecs_cluster.jarombek-com-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.jarombek-com-database-task.arn}"
  desired_count = "${var.jarombek_com_database_desired_count}"
  launch_type = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.jarombek-com-ecs-sg.id}"]
    subnets = [
      "${data.aws_subnet.jarombek-com-yeezus-public-subnet.id}",
      "${data.aws_subnet.jarombek-com-yandhi-public-subnet.id}"
    ]
  }

  load_balancer {
    target_group_arn = "${var.jarombek-com-lb-target-group}"
    container_name = "jarombek-com-database"
    container_port = 27017
  }
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
    to_port = 443
    security_groups = ["${var.alb_security_group}"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}