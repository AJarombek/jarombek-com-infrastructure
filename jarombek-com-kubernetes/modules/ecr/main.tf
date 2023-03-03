/**
 * Docker image repositories in Elastic Container Registry for the jarombek.com application.
 * Author: Andrew Jarombek
 * Date: 9/25/2020
 */

resource "aws_ecr_repository" "jarombek-com-repository" {
  name                 = "jarombek-com"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "jarombek-com-container-repository"
    Application = "jarombek-com"
    Environment = "all"
  }
}

resource "aws_ecr_repository" "jarombek-com-database-repository" {
  name                 = "jarombek-com-database"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "jarombek-com-database-container-repository"
    Application = "jarombek-com"
    Environment = "all"
  }
}