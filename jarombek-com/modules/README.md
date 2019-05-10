### Overview

There are currently two modules for creating the web application - `alb` and `ecs`.  The first creates a load balancer 
for the `jarombek.com` application.  The second creates an ECS cluster for the `jarombek-com` and 
`jarombek-com-database` Docker containers.

### Directories

| Directory Name    | Description                                                                     |
|-------------------|---------------------------------------------------------------------------------|
| `alb`             | Terraform module for a load balancer that forwards requests to the ECS cluster. |
| `ecs`             | Terraform module for an ECS cluster containing the web app and database.        |