### Overview

Module for creating an ECS cluster for the `jarombek.com` application.  The ECS cluster contains `jarombek-com` and 
`jarombek-com-database` Docker containers.  The module is passed variables which determine the app environment.

### Containers

Docker containers used in the ECS cluster.

| Dockerfile                                      | Image Repository                          |
|-------------------------------------------------|-------------------------------------------|
| [jarombek-com](https://bit.ly/2PUZjYp)          | [DockerHub](https://dockr.ly/2vLmcV1)     |
| [jarombek-com-database](https://bit.ly/2Jc41QY) | [DockerHub](https://dockr.ly/2DWt5ao)     |

### Files

| Filename          | Description                                                                                  |
|-------------------|----------------------------------------------------------------------------------------------|
| `container-def/`  | JSON files representing container definitions for ECS tasks.                                 |
| `main.tf`         | Main Terraform file for the `ecs` module.                                                    |
| `var.tf`          | Input variables to pass into the main Terraform file.                                        |