############################################################
# INPUT VARIABLES
############################################################
variable "namespace" {
  type        = string
  default     = "appdynamics"
  description = "Namespace used for deploying the AppDynamics objects. This namespace has to exist and is not provisioned by this module."
}

variable "create_namespace" {
  type        = string
  default     = true
  description = "Determines if the namespace should be created by the module."
}


variable "deploy_clusteragent" {
  type        = string
  default     = true
  description = "Determines if the Cluster Agent should be deployed."
}

variable "deploy_dbcollector" {
  type        = string
  default     = true
  description = "Determines if the DB Collector should be deployed."
}


variable "cluster_name" {
  type        = string
  description = "The name that should be used to represent the Kubernetes cluster and the DB Collector in the AppDynamics UI."
}


variable "appd_controller_url" {
  type        = string
  description = "The URL of the AppDynamics controller, including port."
}

variable "appd_controller_hostname" {
  type        = string
  description = "The nostname of the AppDynamics controller."
}

variable "appd_controller_port" {
  type        = number
  default     = 443
  description = ""
}

variable "appd_controller_ssl" {
  type        = bool
  default     = true
  description = ""
}

variable "appd_account_name" {
  type        = string
  description = ""
}

variable "appd_global_account" {
  type        = string
  description = ""
}

variable "appd_controller_key" {
  type        = string
  description = ""
}

variable "appd_username" {
  type        = string
  description = ""
}

variable "appd_password" {
  type        = string
  description = ""
}


variable "proxy_url" {
  type        = string
  default     = ""
  description = "URL of the proxy used for establishing connections to the AppDynamics controller. You can ignore this parameter if no proxy is used."
}

variable "proxy_host" {
  type        = string
  default     = ""
  description = ""
}

variable "proxy_port" {
  type        = string
  default     = ""
  description = ""
}


variable "ns_to_monitor" {
  type        = list
  default     = ["default", "kube-system", "kube-public", "kube-node-lease", "iks", "appdynamics"]
  description = "The list of namespaces to monitor."
}

variable "ns_to_instrument" {
  type        = string
  default     = "default"
  description = "The namespace(s) to instrument."
}

variable "instrumentation_app_name" {
  type        = string
  default     = "app"
  description = "The application that the instrumented components will be assigned to."
}

variable "db_name" {
  type        = string
  description = ""
}

variable "db_type" {
  type        = string
  description = ""
}

variable "db_hostname" {
  type        = string
  description = ""
}

variable "db_port" {
  type        = string
  description = ""
}

variable "db_username" {
  type        = string
  description = ""
}

variable "db_password" {
  type        = string
  description = ""
}
