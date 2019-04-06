# jarombek-com-infrastructure

## Overview

AWS Infrastructure for the website [jarombek.com](https://jarombek.com).  This is application specific infrastructure, 
existing inside my [Global AWS Infrastructure](https://github.com/AJarombek/global-aws-infrastructure).

### Directories

| Directory Name         | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `acm`                  | HTTPS certificates for the website.                                         |
| `bastion`              | Bastion host to connect to resources in the private VPC.                    |
| `database`             | Infrastructure for the applications persistent data storage.                |
| `jarombek-com-assets`  | Infrastructure for the S3 bucket, which exposes an API for assets.          |
| `jarombek-com-fn`      | Infrastructure for the AWS Lambda functions used by the website.            |
| `key`                  | Generate SSH keys.                                                          |
| `route53`              | DNS for the application.                                                    |
| `web-server`           | Infrastructure for the main web application.                                |