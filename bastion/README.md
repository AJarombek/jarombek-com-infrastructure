### Overview

Infrastructure for a Bastion host, which connects to the private resources in the VPC.  A Bastion host is needed because 
resources inside private VPCs are not publicly available outside the VPC.

### Commands

```bash
terraform init
terraform plan
sudo -s
terraform apply -auto-approve
```

### Dependencies

Depends on the `key-gen` module.  The Bastion host needs access to the EC2 SSH key, which is created in that module for 
the entire `jarombek.com` application infrastructure.

### Files

| Filename                | Description                                                                                      |
|-------------------------|--------------------------------------------------------------------------------------------------|
| `main.tf`               | Terraform script for creating a Bastion host in the `jarombek-com-yandhi-public-subnet` subnet.  |