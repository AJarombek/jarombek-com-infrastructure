/**
 * Testing Kubernetes infrastructure in the 'jarombek-com' or 'jarombek-com-dev' namespaces.
 * Author: Andrew Jarombek
 * Date: 4/10/2021
 */

package main

import (
	k8sfuncs "github.com/ajarombek/cloud-modules/kubernetes-test-functions"
	"testing"
)

// TestJarombekComNamespaceDeploymentCount determines if the number of 'Deployment' objects in the 'jarombek-com'
// (or 'jarombek-com-dev') namespace is as expected.
func TestJarombekComNamespaceDeploymentCount(t *testing.T) {
	k8sfuncs.ExpectedDeploymentCount(t, ClientSet, namespace, 2)
}

// TestJarombekComNamespaceServiceCount determines if the expected number of Service objects exist in the 'jarombek-com'
// (or 'jarombek-com-dev') namespace.
func TestJarombekComNamespaceServiceCount(t *testing.T) {
	k8sfuncs.NamespaceServiceCount(t, ClientSet, namespace, 2)
}

// TestJarombekComNamespaceIngressCount determines if the number of 'Ingress' objects in the 'jarombek-com'
// (or 'jarombek-com-dev') namespace is as expected.
func TestJarombekComNamespaceIngressCount(t *testing.T) {
    // TODO Fix Ingress Tests
	t.Skip("Skipping test due to k8s client issue")

	k8sfuncs.NamespaceIngressCount(t, ClientSet, namespace, 1)
}