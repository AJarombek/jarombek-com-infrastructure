### Overview

`jarombek.com` web application and database Kubernetes infrastructure in different environments.

### Directories

| Directory Name    | Description                                                                                     |
|-------------------|-------------------------------------------------------------------------------------------------|
| `dev`             | Terraform config to build Kubernetes objects for `jarombek.com` in *DEV*.                       |
| `prod`            | Terraform config to build Kubernetes objects for `jarombek.com` in *PROD*.                      |
| `all`             | Terraform config to build an ECR repository for `jarombek.com`.                                 |