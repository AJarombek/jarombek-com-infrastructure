### Overview

Module for creating an Application Load Balancer for the `jarombek.com` application.  The load balancer forwards HTTPS 
requests to an ECS cluster containing application containers.  The module is passed variables which determine the app 
environment.

### Files

| Filename          | Description                                                                                  |
|-------------------|----------------------------------------------------------------------------------------------|
| `main.tf`         | Main Terraform file for the `alb` module.                                                    |
| `var.tf`          | Input variables to pass into the main Terraform file.                                        |
| `outputs.tf`      | Output variables for use outside the Terraform module.                                       |