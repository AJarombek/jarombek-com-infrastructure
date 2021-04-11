// Go module definition for the jarombek-com-infrastructure/test-k8s module.
// Author: Andrew Jarombek
// Date: 4/10/2021

module github.com/ajarombek/jarombek-com-infrastructure/test-k8s

go 1.14

require (
	github.com/ajarombek/cloud-modules/kubernetes-test-functions v0.2.10
	k8s.io/apimachinery v0.17.3-beta.0
	k8s.io/client-go v0.17.0
)
