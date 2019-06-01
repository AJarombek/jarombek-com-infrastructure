### Overview

Create an S3 bucket which is accessible from `asset.jarombek.com`.  It holds images and fonts used by the `jarombek.com` 
website.

### Files

| Filename            | Description                                                                             |
|---------------------|-----------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform code to build the S3 bucket and the objects it holds.                    |
| `policy.json`       | IAM policy for the `asset.jarombek.com` S3 bucket.                                      |
| `www-policy.json`   | IAM policy for the `www.asset.jarombek.com` S3 bucket.                                  |