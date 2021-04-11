### Overview

Creates Kubernetes objects and ECR infrastructure for `jarombek.com`.

### Commands

**Debugging Jarombek Com Pods**

```bash
cd ~/<repos-dir>/global-aws-infrastructure/eks
export KUBECONFIG=~/Documents/global-aws-infrastructure/eks/kubeconfig_andrew-jarombek-eks-cluster

kubectl get po -n jarombek-com 
kubectl logs -f jarombek-com-database-podname -n jarombek-com
```

### Directories

| Directory Name    | Description                                                                                     |
|-------------------|-------------------------------------------------------------------------------------------------|
| `env`             | Terraform configuration to build infrastructure for *DEV*, *PROD*, and global environments.     |
| `modules`         | Modules for building Kubernetes objects and ECR infrastructure.                                 |