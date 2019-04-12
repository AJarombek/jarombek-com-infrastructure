### Overview

The Base AMI which all other application AMIs are built on top of.  Installs dependencies used by the application on top 
of Amazon Linux.

1) **Create `base` AMI**
2) Create `app` AMI
3) Create `dev` or `prod` AMI

### Commands

```bash
packer validate image.json
packer build image.json
```

### Files

| Filename                 | Description                                                                                      |
|--------------------------|--------------------------------------------------------------------------------------------------|
| `provisioners/`          | Provisioners for installing software on the AMI.                                                 |
| `image.json`             | Packer configuration for building the AMI.                                                       |