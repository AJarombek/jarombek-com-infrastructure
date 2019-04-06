### Overview

Terraform module for creating SSH keys used for cloning private repositories from GitHub.  This module could easily be 
strictly Bash, but for consistency its wrapped in Terraform. 

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
| `var.tf`            | Variables containing names for all the SSH keys.                                   |
| `key-gen.sh`        | Bash script which generates SSH keys and places them in the appropriate locations. |