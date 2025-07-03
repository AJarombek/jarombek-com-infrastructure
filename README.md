# jarombek-com-infrastructure

## Overview

AWS Infrastructure for the website [jarombek.com](https://jarombek.com).  This is application specific infrastructure, 
existing inside my [Global AWS Infrastructure](https://github.com/AJarombek/global-aws-infrastructure).

### Directories

| Directory Name                    | Description                                                                |
|-----------------------------------|----------------------------------------------------------------------------|
| `.github`                         | GitHub Actions for CI/CD pipelines.                                        |
| `acm`                             | HTTPS certificates for the website.                                        |
| `dynamodb`                        | DynamoDB tables for handling subscriptions.                                |
| `iam`                             | IAM roles and policies for the AWS infrastructure.                         |
| `jarombek-com-assets`             | Infrastructure for the S3 bucket, which exposes an API for assets.         |
| `jarombek-com-fn`                 | Infrastructure for the AWS Lambda functions used by the website.           |
| `jarombek-com-kubernetes`         | Kubernetes infrastructure for the website and database.                    |
| `jarombek-com-kubernetes-ingress` | Kubernetes Ingress infrastructure for the website and database.            |
| `route53`                         | DNS for the application.                                                   |
| `test`                            | Python AWS infrastructure test suite written with boto3 AWS SDK.           |
| `test-k8s`                        | Go Kubernetes infrastructure test suite.                                   |

### Version History

**[v1.1.5](https://github.com/AJarombek/jarombek-com-infrastructure/tree/v1.1.5) - Remove Unused ACM Certs & CloudFront**

> Release Date: January 28th, 2024

+ Remove unused ACM certificates and CloudFront distributions.

**[v1.1.4](https://github.com/AJarombek/jarombek-com-infrastructure/tree/v1.1.4) - Remove React 16.3 Demo Infrastructure**

> Release Date: December 22nd, 2023

+ React 16.3 Demo Infrastructure Moved to [andy-jarombek-research](https://github.com/AJarombek/andy-jarombek-research)

**[v1.1.3](https://github.com/AJarombek/jarombek-com-infrastructure/tree/v1.1.3) - Kubernetes Tests Upgraded**

> Release Date: June 4th, 2023

+ Kubernetes Ingress tests fixed
+ Kubernetes tests upgraded to Go 1.20

**[v1.1.2](https://github.com/AJarombek/jarombek-com-infrastructure/tree/v1.1.2) - EKS V2 Cluster**

> Release Date: April 2nd, 2023

Integrate the website and API with the EKS V2 Cluster.

**[v1.1.1](https://github.com/AJarombek/jarombek-com-infrastructure/tree/v1.1.1) - GitHub Actions**

> Release Date: March 2nd, 2023

Integrate Terraform formatting, AWS tests, and Kubernetes tests with GitHub Actions CI/CD.

**[v1.1.0](https://github.com/AJarombek/jarombek-com-infrastructure/tree/v1.1.0) - Jarombek.com S3 Bucket Updates**

> Release Date: December 27th, 2021

This release updated the S3 buckets in my infrastructure, making those used as static websites private.
