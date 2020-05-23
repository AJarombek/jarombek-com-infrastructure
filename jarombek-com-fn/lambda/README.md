### Overview

Module to create AWS Lambda functions required by `jarombek.com`.

### Files

| Filename                      | Description                                                                             |
|-------------------------------|-----------------------------------------------------------------------------------------|
| `lambda-logging-policy.json`  | IAM policy for CloudWatch logs used by the Lambda function.                             |
| `lambda-role.json`            | IAM assume role policy for the Lambda function to use.                                  |
| `main.tf`                     | Main Terraform code to build Lambda function infrastructure.                            |
| `outputs.tf`                  | Output variables for the module to export.                                              |