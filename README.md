# jarombek-com-infrastructure

## Overview

AWS Infrastructure for the website [jarombek.com](https://jarombek.com).  This is application specific infrastructure, 
existing inside my [Global AWS Infrastructure](https://github.com/AJarombek/global-aws-infrastructure).

### Directories

| Directory Name                    | Description                                                                |
|-----------------------------------|----------------------------------------------------------------------------|
| `acm`                             | HTTPS certificates for the website.                                        |
| `dynamodb`                        | DynamoDB tables for handling subscriptions.                                |
| `iam`                             | IAM roles and policies for the AWS infrastructure.                         |
| `jarombek-com`                    | *DEPRECATED* ECS Infrastructure for the main web application and database. |
| `jarombek-com-assets`             | Infrastructure for the S3 bucket, which exposes an API for assets.         |
| `jarombek-com-fn`                 | Infrastructure for the AWS Lambda functions used by the website.           |
| `jarombek-com-kubernetes`         | Kubernetes infrastructure for the website and database.                    |
| `jarombek-com-kubernetes-ingress` | Kubernetes Ingress infrastructure for the website and database.            |
| `jarombek-com-react16-3-demo`     | Infrastructure for an S3 bucket that hosts the React 16.3 demo static app. |
| `route53`                         | DNS for the application.                                                   |
| `test`                            | Python AWS infrastructure test suite written with boto3 AWS SDK.           |
| `test-k8s`                        | Go Kubernetes infrastructure test suite.                                   |

### Version History

**[v1.1.1](https://github.com/AJarombek/jarombek-com-infrastructure/tree/v1.1.1) - GitHub Actions**

> Release Date: March 2nd, 2023

Integrate Terraform formatting, AWS tests, and Kubernetes tests with GitHub Actions CI/CD.

**[v1.1.0](https://github.com/AJarombek/jarombek-com-infrastructure/tree/v1.1.0) - Jarombek.com S3 Bucket Updates**

> Release Date: December 27th, 2021

This release updated the S3 buckets in my infrastructure, making those used as static websites private.
