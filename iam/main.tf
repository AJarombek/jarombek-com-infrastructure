/**
 * IAM Policies and Roles for the jarombek-com application infrastructure
 * Author: Andrew Jarombek
 * Date: 5/2/2019
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 3.36.0"
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "jarombek-com-infrastructure/iam"
    region  = "us-east-1"
  }
}

# ---------
# IAM Roles
# ---------

resource "aws_iam_role" "ecs-task-role" {
  name               = "ecs-task-role"
  path               = "/admin/"
  assume_role_policy = file("policies/ecs-tasks-assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy" {
  policy_arn = aws_iam_policy.ecs-task-policy.arn
  role       = aws_iam_role.ecs-task-role.name
}

# ------------
# IAM Policies
# ------------

resource "aws_iam_policy" "ecs-task-policy" {
  name   = "ecs-task-policy"
  path   = "/jarombek-com/"
  policy = file("policies/ecs-task-policy.json")
}