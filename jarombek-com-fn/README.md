### Overview

AWS Lambda functions exposed through an API Gateway.  API Gateway uses the `fn.jarombek.com` domain.

### Files

| Filename            | Description                                                                             |
|---------------------|-----------------------------------------------------------------------------------------|
| `api-gateway/`      | Infrastructure creating an API Gateway for lambda functions called by `jarombek.com`    |
| `lambda/`           | Lambda functions exposed through API Gateway                                            |
| `main.tf`           | The main Terraform module which invokes `api-gateway` and `lambda`                      |