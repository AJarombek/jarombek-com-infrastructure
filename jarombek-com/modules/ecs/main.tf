/**
 * The websites ECS cluster
 * Author: Andrew Jarombek
 * Date: 4/13/2019
 */

locals {
  env           = var.prod ? "prod" : "dev"
  env_tag       = var.prod ? "production" : "development"
  container_def = var.prod ? "jarombek-com.json" : "dev-jarombek-com.json"
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

data "aws_iam_role" "ecs-task-role" {
  name = "ecs-task-role"
}

#---------------------
# ECS Cluser Resources
#---------------------

/*
  Get dependencies from other modules.  When a resource 'depends_on' the dependency-getter, it effectively depends on
  resources in the other module.  Based off the following design:
  https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
*/
resource "null_resource" "dependency-getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

resource "aws_ecs_cluster" "jarombek-com-ecs-cluster" {
  name = "jarombek-com-${local.env}-ecs-cluster"

  tags = {
    Name        = "jarombek-com-${local.env}-ecs-cluster"
    Application = "jarombek-com"
    Environment = local.env_tag
  }
}

resource "aws_cloudwatch_log_group" "jarombek-com-ecs-task-logs" {
  name              = "/ecs/fargate-tasks"
  retention_in_days = 7

  tags = {
    Name        = "ecs-fargate-tasks"
    Application = "jarombek-com"
    Environment = local.env_tag
  }
}

resource "aws_ecs_task_definition" "jarombek-com-task" {
  family                   = "jarombek-com"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = data.aws_iam_role.ecs-task-role.arn
  cpu                      = 256
  memory                   = 512

  container_definitions = file("${path.module}/container-def/${local.container_def}")

  tags = {
    Name        = "jarombek-com-ecs-${local.env}-task"
    Application = "jarombek-com"
    Environment = local.env_tag
  }

  depends_on = [
    null_resource.dependency-getter,
    aws_cloudwatch_log_group.jarombek-com-ecs-task-logs
  ]
}

resource "aws_ecs_service" "jarombek-com-service" {
  name            = "jarombek-com-ecs-${local.env}-service"
  cluster         = aws_ecs_cluster.jarombek-com-ecs-cluster.id
  task_definition = aws_ecs_task_definition.jarombek-com-task.arn
  desired_count   = var.jarombek_com_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.jarombek-com-ecs-sg.id]
    subnets = [
      data.aws_subnet.jarombek-com-yeezus-public-subnet.id,
      data.aws_subnet.jarombek-com-yandhi-public-subnet.id
    ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.jarombek-com-lb-target-group
    container_name   = "jarombek-com"
    container_port   = 8080
  }

  tags = {
    Name        = "jarombek-com-ecs-${local.env}-service"
    Application = "jarombek-com"
    Environment = local.env_tag
  }

  depends_on = [null_resource.dependency-getter]
}

resource "aws_security_group" "jarombek-com-ecs-sg" {
  name   = "jarombek-com-${local.env}-ecs-security-group"
  vpc_id = data.aws_vpc.jarombek-com-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "jarombek-com-${local.env}-ecs-security-group"
    Application = "jarombek-com"
    Environment = local.env_tag
  }
}