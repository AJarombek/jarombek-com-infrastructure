### Overview

The development environment AMI.  Configures the image with environment specific details.  This is a final image used to 
build a web server VM (EC2 instance). 

1) Create `base` AMI
2) Create `app` AMI
3) **Create `dev` AMI**

### Files

| Filename                 | Description                                                                                      |
|--------------------------|--------------------------------------------------------------------------------------------------|
| `image.json`             | Packer configuration for building the AMI.                                                       |
| `playbook.yml`           | Ansible Playbook used for setting up Certbot HTTPS certificates on the AMI.                      |
| `config.nginx`           | Nginx web server config file.                                                                    |