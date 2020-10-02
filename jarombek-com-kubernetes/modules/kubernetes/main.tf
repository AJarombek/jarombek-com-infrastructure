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
  short_version = "1.2.0"
  version = "v${local.short_version}"
  account_id = data.aws_caller_identity.current.account_id
}

#---------------------------------------------------------------------
# Kubernetes Resources for the jarombek.com Web Application & Database
#---------------------------------------------------------------------

resource "kubernetes_deployment" "web-deployment" {
  metadata {
    name = "jarombek-com"
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

  depends_on = [kubernetes_deployment.database-deployment, kubernetes_service.database-service]
}

resource "kubernetes_service" "web-service" {
  metadata {
    name = "jarombek-com"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "jarombek-com"
      task = "web"
    }
  }

  spec {
    type = "NodePort"

    port {
      port = 80
      target_port = 80
      protocol = "TCP"
    }

    selector = {
      application = "jarombek-com"
      task = "web"
    }
  }
}

resource "kubernetes_deployment" "database-deployment" {
  metadata {
    name = "jarombek-com-database"
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

resource "kubernetes_service" "database-service" {
  metadata {
    name = "jarombek-com-database"
    namespace = local.namespace

    labels = {
      version = local.version
      environment = local.env
      application = "jarombek-com"
      task = "database"
    }
  }

  spec {
    type = "NodePort"

    port {
      port = 27017
      target_port = 27017
      protocol = "TCP"
    }

    selector = {
      application = "jarombek-com"
      task = "database"
    }
  }
}