### Overview

Contains files that create a web server.  There are two main steps to create the web server.  The first step is to
build AMIs with Packer.  This is done in the `ami` directory.  The second step is to execute the Terraform scripts, 
creating a launch configuration and auto-scaling group for the web server.

### Files

| Filename                 | Description                                                                                      |
|--------------------------|--------------------------------------------------------------------------------------------------|
| `ami/`                   | Creates AMIs that the web server will run on.                                                    |
| `main.tf`                | Main Terraform script for the web server module.                                                 |
| `var.tf`                 | Variables to pass into the main Terraform script.                                                |
| `server.yml`             | CloudFormation template for the launch configuration.  Invoked by the main Terraform script.     |
| `key-gen.sh`             | Bash script executed before the terraform scripts run.  Creates a private key for EC2 debugging. |