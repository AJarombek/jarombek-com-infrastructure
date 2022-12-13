/**
 * DynamoDB tables for the jarombek-com application
 * Author: Andrew Jarombek
 * Date: 12/12/2022
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.1.2"

  required_providers {
    aws = ">= 4.46.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "jarombek-com-infrastructure/dynamodb"
    region = "us-east-1"
  }
}

resource "aws_dynamodb_table" "jarombek-com-subscribers" {
  name = "jarombek-com-subscribers"
  billing_mode = "PROVISIONED"
  read_capacity = 20
  write_capacity = 20

  hash_key = "email"

  attribute {
    name = "email"
    type = "S"
  }

  tags = {
    Name = "jarombek-com-subscribers"
    Application = "jarombek-com"
    Environment = "production"
  }
}

resource "aws_dynamodb_table_item" "me" {
  table_name = aws_dynamodb_table.jarombek-com-subscribers.name
  hash_key = aws_dynamodb_table.jarombek-com-subscribers.hash_key
  item = jsonencode({
    "email" = {"S" = "andrew@jarombek.com"},
    "subscribed" = {"BOOL" = true},
    "created" = {"S" = "2022-12-12"},
    "updated" = {"S" = "2022-12-12"}
  })
}