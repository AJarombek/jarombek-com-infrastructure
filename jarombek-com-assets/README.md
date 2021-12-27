### Overview

Create an S3 bucket which is accessible from `asset.jarombek.com`.  It holds images and fonts used by the `jarombek.com` 
website.

### Files

| Filename            | Description                                                                             |
|---------------------|-----------------------------------------------------------------------------------------|
| `main.tf`           | Main Terraform code to build the S3 bucket and the objects it holds.                    |

### Resources

1) [s3_bucket_object Terraform Documentation](https://www.terraform.io/docs/providers/aws/r/s3_bucket_object.html)
2) [Clear AWS CloudFront Cache](http://www.technowise.in/2012/09/clear-cache-from-amazon-cloudfront-aws.html)
3) [SVG MIME Content-Type Header](https://css-tricks.com/snippets/htaccess/serve-svg-correct-content-type/)