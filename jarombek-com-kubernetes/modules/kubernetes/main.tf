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

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command = "aws"
    args = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
  }
}

#----------------
# Local Variables
#----------------

locals {
  short_env = var.prod ? "prod" : "dev"
  env = var.prod ? "production" : "development"
  namespace = var.prod ? "jarombek-com" : "jarombek-com-dev"
  web_short_version = "1.1.16"
  web_version = "v${local.web_short_version}"
  database_short_version = "1.1.16"
  database_version = "v${local.database_short_version}"
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
      version = local.web_version
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
        version = local.web_version
        environment = local.env
        application = "jarombek-com"
        task = "web"
      }
    }

    template {
      metadata {
        labels = {
          version = local.web_version
          environment = local.env
          application = "jarombek-com"
          task = "web"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key = "workload"
                  operator = "In"
                  values = ["production-applications"]
                }
              }
            }
          }
        }

        container {
          name = "jarombek-com"
          image = "ajarombek/jarombek-com:${local.web_short_version}"

          readiness_probe {
            period_seconds = 5
            initial_delay_seconds = 20

            http_get {
              path = "/"
              port = 8080
            }
          }

          port {
            container_port = 8080
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
      version = local.web_version
      environment = local.env
      application = "jarombek-com"
      task = "web"
    }
  }

  spec {
    type = "NodePort"

    port {
      port = 80
      target_port = 8080
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
      version = local.database_version
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
        version = local.database_version
        environment = local.env
        application = "jarombek-com"
        task = "database"
      }
    }

    template {
      metadata {
        labels = {
          version = local.database_version
          environment = local.env
          application = "jarombek-com"
          task = "database"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key = "workload"
                  operator = "In"
                  values = ["production-applications"]
                }
              }
            }
          }
        }

        container {
          name = "jarombek-com-database"
          image = "ajarombek/jarombek-com-database:${local.database_short_version}"

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
      version = local.database_version
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