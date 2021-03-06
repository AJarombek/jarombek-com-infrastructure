### Commands

**Running the Go tests locally**

```bash
# Run the Kubernetes tests using the local Kubeconfig file.  Set TEST_ENV to either 'dev' or 'prod'.
export TEST_ENV=<dev|prod>
go test --kubeconfig ~/Documents/global-aws-infrastructure/eks/kubeconfig_andrew-jarombek-eks-cluster
```

### Files

| Filename                   | Description                                                                                  |
|----------------------------|----------------------------------------------------------------------------------------------|
| `client.go`                | Kubernetes client creation.                                                                  |
| `main_test.go`             | Setup functions for Kubernetes tests.                                                        |
| `namespace_test.go`        | Kubernetes tests for the `jarombek-com` and `jarombek-com-dev` namespaces.                   |
| `jarombek_com_test.go`     | Kubernetes tests for `jarombek.com` Kubernetes objects.                                      |
| `go.mod`                   | Go module definition and dependency specification.                                           |
| `go.sum`                   | Versions of modules installed as dependencies for this Go module.                            |
