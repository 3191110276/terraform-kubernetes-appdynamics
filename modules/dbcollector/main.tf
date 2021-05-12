############################################################
# REQUIRED PROVIDERS
############################################################
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    appdynamics = {
      source = "3191110276/appdynamics"
      version = "0.1.1"
    }
  }
}


############################################################
# INSTALL APPDYNAMICS DB COLLECTOR
############################################################
resource "kubernetes_config_map" "dbcollector" {
  metadata {
    name = "dbcollector-config"
    namespace = var.namespace
  }

  data = {
    ACCOUNT_NAME    = var.appd_account_name
    CONTROLLER_HOST = var.appd_controller_hostname
    CONTROLLER_PORT = var.appd_controller_port
    CONTROLLER_SSL  = var.appd_controller_ssl
    ACCESS_KEY      = var.appd_controller_key
    APP_NAME        = var.app_name
    PROXY_HOST      = var.proxy_host
    PROXY_PORT      = var.proxy_port
  }
}

resource "kubernetes_deployment" "dbcollector" {
  wait_for_completion = true
  timeouts {
    create = "900s"
  }
  
  metadata {
    name      = "appd-dbagent"
    namespace = var.namespace
    labels    = {
      app = "appd-dbagent"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "appd-dbagent"
      }
    }

    template {
      metadata {
        labels = {
          app = "appd-dbagent"
        }
      }

      spec {
        container {
          image = "${var.registry}/${var.image_name}:${var.image_tag}"
          name  = "appd-dbagent"
          env_from {
            config_map_ref {
              name = "dbcollector-config"
            }
          }
        }
      }
    }
  }
}


############################################################
# CREATE DB COLLECTOR IN APPD
############################################################
resource "appdynamics_db_collector" "main" {

  depends_on = [kubernetes_deployment.dbcollector]

  name = var.db_name

  agent_name = var.db_name

  type = var.db_type

  hostname = var.db_hostname
  port     = var.db_port
  username = var.db_username
  password = var.db_password
}
