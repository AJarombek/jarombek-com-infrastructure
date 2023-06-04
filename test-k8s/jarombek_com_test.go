/**
 * Testing Kubernetes infrastructure for the application 'jarombek.com'.
 * Author: Andrew Jarombek
 * Date: 4/11/2021
 */

package main

import (
	"context"
	"fmt"
	k8sfuncs "github.com/ajarombek/cloud-modules/kubernetes-test-functions"
	v1meta "k8s.io/apimachinery/pkg/apis/meta/v1"
	"testing"
)

// TestJarombekComDeploymentExists determines if a deployment exists in the 'jarombek-com' (or 'jarombek-com-dev')
// namespace with the name 'jarombek-com'.
func TestJarombekComDeploymentExists(t *testing.T) {
	k8sfuncs.DeploymentExists(t, ClientSet, "jarombek-com", namespace)
}

// TestJarombekComDeploymentErrorFree determines if the 'jarombek-com' deployment is running error free.
func TestJarombekComDeploymentErrorFree(t *testing.T) {
	k8sfuncs.DeploymentStatusCheck(t, ClientSet, "jarombek-com", namespace, true, true, 1, 1, 1, 0)
}

// TestJarombekComServiceExists determines if a NodePort Service with the name 'jarombek-com' exists in the
// 'jarombek-com' (or 'jarombek-com-dev') namespace.
func TestJarombekComServiceExists(t *testing.T) {
	k8sfuncs.ServiceExists(t, ClientSet, "jarombek-com", namespace, "NodePort")
}

// TestJarombekComDatabaseDeploymentExists determines if a deployment exists in the 'jarombek-com'
// (or 'jarombek-com-dev') namespace with the name 'jarombek-com-database'.
func TestJarombekComDatabaseDeploymentExists(t *testing.T) {
	k8sfuncs.DeploymentExists(t, ClientSet, "jarombek-com-database", namespace)
}

// TestJarombekComDatabaseDeploymentErrorFree determines if the 'jarombek-com-database' deployment is running
// error free.
func TestJarombekComDatabaseDeploymentErrorFree(t *testing.T) {
	k8sfuncs.DeploymentStatusCheck(t, ClientSet, "jarombek-com-database", namespace, true, true, 1, 1, 1, 0)
}

// TestJarombekComDatabaseServiceExists determines if a NodePort Service with the name 'jarombek-com-database' exists
// in the 'jarombek-com' (or 'jarombek-com-dev') namespace.
func TestJarombekComDatabaseServiceExists(t *testing.T) {
	k8sfuncs.ServiceExists(t, ClientSet, "jarombek-com-database", namespace, "NodePort")
}

// TestJarombekComIngressExists determines if an ingress object exists in the 'jarombek-com' (or 'jarombek-com-dev')
// namespace with the name 'jarombek-com-ingress'.
func TestJarombekComIngressExists(t *testing.T) {
	k8sfuncs.IngressExists(t, ClientSet, namespace, "jarombek-com-ingress")
}

// TestJarombekComIngressAnnotations determines if the 'jarombek-com-ingress' Ingress object contains the expected annotations.
func TestJarombekComIngressAnnotations(t *testing.T) {
	ingress, err := ClientSet.NetworkingV1().Ingresses(namespace).Get(context.TODO(), "jarombek-com-ingress", v1meta.GetOptions{})

	if err != nil {
		panic(err.Error())
	}

	var hostname string
	var environment string
	if env == "dev" {
		hostname = "dev.jarombek.com,www.dev.jarombek.com"
		environment = "development"
	} else {
		hostname = "jarombek.com,www.jarombek.com"
		environment = "production"
	}

	annotations := ingress.Annotations

	// Kubernetes Ingress class and ExternalDNS annotations
	k8sfuncs.AnnotationsEqual(t, annotations, "kubernetes.io/ingress.class", "alb")
	k8sfuncs.AnnotationsEqual(t, annotations, "external-dns.alpha.kubernetes.io/hostname", hostname)

	// ALB Ingress annotations
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/actions.ssl-redirect", "{\"Type\": \"redirect\", \"RedirectConfig\": {\"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/backend-protocol", "HTTP")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/scheme", "internet-facing")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/listen-ports", "[{\"HTTP\":80}, {\"HTTPS\":443}]")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/healthcheck-path", "/")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/healthcheck-protocol", "HTTP")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/target-type", "instance")
	k8sfuncs.AnnotationsEqual(t, annotations, "alb.ingress.kubernetes.io/tags", "Name=jarombek-com-load-balancer,Application=jarombek-com,Environment="+environment)

	// ALB Ingress annotations pattern matching
	uuidPattern := "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
	certificateArnPattern := fmt.Sprintf("arn:aws:acm:us-east-1:739088120071:certificate/%s", uuidPattern)
	certificatesPattern := fmt.Sprintf("^%s,%s$", certificateArnPattern, certificateArnPattern)
	k8sfuncs.AnnotationsMatchPattern(t, annotations, "alb.ingress.kubernetes.io/certificate-arn", certificatesPattern)

	sgPattern := "^sg-[0-9a-f]+$"
	k8sfuncs.AnnotationsMatchPattern(t, annotations, "alb.ingress.kubernetes.io/security-groups", sgPattern)

	subnetsPattern := "^subnet-[0-9a-f]+,subnet-[0-9a-f]+$"
	k8sfuncs.AnnotationsMatchPattern(t, annotations, "alb.ingress.kubernetes.io/subnets", subnetsPattern)

	expectedAnnotationsLength := 13
	annotationLength := len(annotations)

	if expectedAnnotationsLength == annotationLength {
		t.Logf(
			"JarombekCom Ingress has the expected number of annotations.  Expected %v, got %v.",
			expectedAnnotationsLength,
			annotationLength,
		)
	} else {
		t.Errorf(
			"JarombekCom Ingress does not have the expected number of annotations.  Expected %v, got %v.",
			expectedAnnotationsLength,
			annotationLength,
		)
	}
}
