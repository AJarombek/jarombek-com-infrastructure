/**
 * Kubernetes infrastructure for the jarombek.com application.
 * Author: Andrew Jarombek
 * Date: 9/26/2020
 */

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = "andrew-jarombek-eks-cluster"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "andrew-jarombek-eks-cluster"
}

data "aws_vpc" "application-vpc" {
  tags = {
    Name = "application-vpc"
  }
}

data "aws_subnet" "kubernetes-dotty-public-subnet" {
  tags = {
    Name = "kubernetes-dotty-public-subnet"
  }
}

data "aws_subnet" "kubernetes-grandmas-blanket-public-subnet" {
  tags = {
    Name = "kubernetes-grandmas-blanket-public-subnet"
  }
}

data "aws_acm_certificate" "jarombek-cert" {
  domain = local.domain_cert
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "jarombek-wildcard-cert" {
  domain = local.wildcard_domain_cert
  statuses = ["ISSUED"]
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
  load_config_file = false
}

#----------------
# Local Variables
#----------------

locals {
  short_env = var.prod ? "prod" : "dev"
  env = var.prod ? "production" : "development"
  namespace = var.prod ? "jarombek-com" : "jarombek-com-dev"
  host1 = var.prod ? "jarombek.com" : "dev.jarombek.com"
  host2 = var.prod ? "www.jarombek.com" : "www.dev.jarombek.com"
  hostname = "${local.host1},${local.host2}"
  short_version = "1.2.0"
  version = "v${local.short_version}"
  account_id = data.aws_caller_identity.current.account_id
  domain_cert = "*.jarombek.com"
  wildcard_domain_cert = "*.dev.jarombek.com"
  cert_arn = data.aws_acm_certificate.jarombek-cert.arn
  wildcard_cert_arn = data.aws_acm_certificate.jarombek-wildcard-cert.arn
  subnet1 = data.aws_subnet.kubernetes-dotty-public-subnet.id
  subnet2 = data.aws_subnet.kubernetes-grandmas-blanket-public-subnet.id
}

#--------------
# AWS Resources
#--------------

resource "aws_security_group" "jarombek-com-lb-sg" {
  name = "jarombek-com-${local.short_env}-lb-security-group"
  vpc_id = data.aws_vpc.application-vpc.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jarombek-com-${local.short_env}-lb-security-group"
    Application = "jarombek-com"
    Environment = local.env
  }
}

#---------------------------------------------------------------------
# Kubernetes Resources for the jarombek.com Web Application & Database
#---------------------------------------------------------------------

resource "kubernetes_deployment" "web-deployment" {
  metadata {
    name = "jarombek-com-deployment"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "jarombek-com"
      task = "web"
    }
  }

  spec {
    replicas = 1
    min_ready_seconds = 10

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge = "1"
        max_unavailable = "0"
      }
    }

    selector {
      match_labels = {
        version = local.version
        environment = local.env
        application = "jarombek-com"
        task = "web"
      }
    }

    template {
      metadata {
        labels = {
          version = local.version
          environment = local.env
          application = "jarombek-com"
          task = "web"
        }
      }

      spec {
        container {
          name = "jarombek-com"
          image = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/jarombek-com:${local.short_version}"

          readiness_probe {
            period_seconds = 5
            initial_delay_seconds = 20

            http_get {
              path = "/"
              port = 80
            }
          }

          port {
            container_port = 80
            protocol = "TCP"
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.database-deployment]
}

resource "kubernetes_deployment" "database-deployment" {
  metadata {
    name = "jarombek-com-database-deployment"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "jarombek-com"
      task = "database"
    }
  }

  spec {
    replicas = 1
    min_ready_seconds = 10

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge = "1"
        max_unavailable = "0"
      }
    }

    selector {
      match_labels = {
        version = local.version
        environment = local.env
        application = "jarombek-com"
        task = "database"
      }
    }

    template {
      metadata {
        labels = {
          version = local.version
          environment = local.env
          application = "jarombek-com"
          task = "database"
        }
      }

      spec {
        container {
          name = "jarombek-com-database"
          image = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/jarombek-com-database:${local.short_version}"

          port {
            container_port = 27017
            protocol = "TCP"
          }

          env {
            name = "NODE_ENV"
            value = local.env
          }
        }
      }
    }
  }
}