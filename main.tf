############################################################
# REQUIRED PROVIDERS
############################################################
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.2"
    }
  }
}


############################################################
# CREATE APPDYNAMICS NAMESPACE
############################################################
resource "kubernetes_namespace" "appdynamics" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}


############################################################
# DEPLOY APPDYNAMICS CLUSTER AGENT
############################################################
module "clusteragent" {
  depends_on = [kubernetes_namespace.appdynamics]

  count = var.deploy_clusteragent ? 1 : 0

  source  = "./modules/clusteragent"

  cluster_name   = var.cluster_name

  appd_controller_url = var.appd_controller_url
  appd_account_name   = var.appd_account_name
  appd_controller_key = var.appd_controller_key
  appd_global_account = var.appd_global_account
  appd_username       = var.appd_username
  appd_password       = var.appd_password

  proxy_url = var.proxy_url

  ns_to_monitor    = var.ns_to_monitor
  ns_to_instrument = var.ns_to_instrument
  
  instrumentation_app_name = var.instrumentation_app_name
}


############################################################
# DEPLOY AND CONFIGURE APPDYNAMICS DB COLLECTOR
############################################################
module "dbcollector" {
  depends_on = [kubernetes_namespace.appdynamics]

  count = var.deploy_dbcollector ? 1 : 0

  source  = "./modules/dbcollector"

  namespace = var.namespace

  app_name                 = var.cluster_name
  appd_account_name        = var.appd_account_name
  appd_controller_hostname = var.appd_controller_hostname
  appd_controller_port     = var.appd_controller_port
  appd_controller_ssl      = var.appd_controller_ssl
  appd_controller_key      = var.appd_controller_key

  proxy_host = var.proxy_host
  proxy_port = var.proxy_port

  db_name      = var.db_name
  db_type      = var.db_type
  db_hostname  = var.db_hostname
  db_port      = var.db_port
  db_username  = var.db_username
  db_password  = var.db_password
}
