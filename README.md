# jarombek-com-infrastructure

## Overview

AWS Infrastructure for the website [jarombek.com](https://jarombek.com).  This is application specific infrastructure, 
existing inside my [Global AWS Infrastructure](https://github.com/AJarombek/global-aws-infrastructure).

### Directories

| Directory Name         | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `acm`                  | HTTPS certificates for the website.                                         |
| `iam`                  | IAM roles and policies for the AWS infrastructure.                          |
| `jarombek-com`         | ECS Infrastructure for the main web application and database.               |
| `jarombek-com-assets`  | Infrastructure for the S3 bucket, which exposes an API for assets.          |
| `jarombek-com-fn`      | Infrastructure for the AWS Lambda functions used by the website.            |
| `route53`              | DNS for the application.                                                    |
| `test`                 | Unit tests for the infrastructure.  Written with boto3 AWS SDK.             |