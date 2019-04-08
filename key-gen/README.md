### Overview

Terraform module for creating SSH keys used for cloning private repositories from GitHub and connecting to EC2 
instances.  This module could easily be strictly Bash, but for consistency its wrapped in Terraform. 

```bash
terraform init
terraform plan
sudo -s
terraform apply -auto-approve
```

### Files

| Filename            | Description                                                                        |
|---------------------|------------------------------------------------------------------------------------|
| `main.tf`           | The main Terraform module which calls the key-gen Bash script.                     |
| `git-key-gen.sh`    | Bash script which generates SSH keys for accessing private repos on GitHub.        |
| `ec2-key-gen.sh`    | Bash script which generates SSH keys for connecting to EC2 instances.              | 