### Overview

The Application AMI which environment specific AMIs are built on top of.  Installs dependencies used by the application 
along with the application itself on top of the 
[base AMI](https://github.com/AJarombek/jarombek-com-infrastructure/tree/master/web-server/modules/server/ami/base).

1) Create `base` AMI
2) **Create `app` AMI**
3) Create `dev` or `prod` AMI

### Commands

```bash
packer validate image.json
packer build image.json
```

### Files

| Filename                 | Description                                                                                      |
|--------------------------|--------------------------------------------------------------------------------------------------|
| `image.json`             | Packer configuration for building the AMI.                                                       |
| `playbook.yml`           | Ansible Playbook used for setting up the Node.js application on the AMI.                         |