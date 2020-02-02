### Overview

Create an S3 bucket which is accessible from `react16-3.demo.jarombek.com`.  It holds JavaScript, HTML, and CSS 
assets for the static website.

### Files

| Filename            | Description                                                                             |
|---------------------|-----------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform code to build the S3 bucket and the objects it holds.                    |
| `policy.json`       | IAM policy for the `react16-3.demo.jarombek.com` S3 bucket.                             |
| `www-policy.json`   | IAM policy for the `www.react16-3.demo.jarombek.com` S3 bucket.                         |
