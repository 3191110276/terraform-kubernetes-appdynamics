############################################################
# INPUT VARIABLES
############################################################
variable "namespace" {
  type        = string
  default     = "appdynamics"
  description = "The Kubernetes namespace in which the Cluster Agent will be deployed. This namespace has to exist and is not provisioned by this module."
}

variable "cluster_name" {
  type        = string
  description = "Name of the Kubernetes cluster in AppDynamics. The value in this field determines how the cluster will be called in the AppDynamics UI."
}

variable "appd_controller_url" {
  type        = string
  default     = ""
  description = "URL of the AppDynamics controller."
}

variable "appd_username" {
  type        = string
  description = "Username used for logging into the AppDynamics account. This will either be your username, or the username of the account created for this integration."
}

variable "appd_password" {
  type        = string
  description = "Password used for logging into the AppDynamics account. This will either be your password, or the password of the account created for this integration."
}

variable "appd_account_name" {
  type        = string
  description = "The name of the AppDynamics account. This value can be found in Settings > License > Account > Name."
}

variable "appd_global_account" {
  type        = string
  description = "The name of the global AppDynamics account. This value can be found in Settings > License > Account > Global Account Name."
}

variable "appd_controller_key" {
  type        = string
  description = "The key used for authorizing with the AppDynamics controller. This value can be found in Settings > License > Account > Access Key."
}

variable "proxy_url" {
  type        = string
  default     = ""
  description = "URL of the proxy used for establishing connections to the AppDynamics controller. You can ignore this parameter if no proxy is used."
}

variable "registry" {
  type        = string
  default     = "mimaurer"
  description = "The registry from which the NodeAgent will be pulled."
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
  default     = "instrumented_app"
  description = "The application that the instrumented components will be assigned to."
}
