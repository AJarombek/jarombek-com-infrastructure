### Overview

The Base AMI which all other application AMIs are built on top of.  Installs dependencies used by the application on top 
of Amazon Linux.

1) **Create `base` AMI**
2) Create `app` AMI
3) Create `dev` or `prod` AMI

### Files

| Filename                 | Description                                                                                      |
|--------------------------|--------------------------------------------------------------------------------------------------|
| `image.json`             | Packer configuration for building the AMI.                                                       |
| `playbook.yml`           | Ansible Playbook used for installing software on the AMI.                                        |
| `setup-image.sh`         | Bash script used to install Ansible on the AMI.                                                  |