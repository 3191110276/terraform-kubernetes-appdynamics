############################################################
# INPUT VARIABLES
############################################################

variable "namespace" {
  type        = string
  default     = "appdynamics"
  description = "The Kubernetes namespace in which the DB collector will be deployed. This namespace has to exist and is not provisioned by this module."
}

variable "appd_account_name" {
  type        = string
  description = "The name of the AppDynamics account. This value can be found in Settings > License > Account > Name."
}

variable "appd_controller_hostname" {
  type        = string
  description = "The nostname of the AppDynamics controller."
}

variable "appd_controller_port" {
  type        = string
  default     = "443"
  description = "The port of the AppDynamics controller."
}

variable "appd_controller_ssl" {
  type        = string
  default     = "true"
  description = "This setting determines if the AppDynamics controller uses SSL. If port 443 is used as the Controller port, this should be set to true."
}

variable "appd_controller_key" {
  type        = string
  description = "The key used for authorizing with the AppDynamics controller. This value can be found in Settings > License > Account > Access Key."
}

variable "app_name" {
  type        = string
  description = "The name of the application to which the DB collector will be associated."
}

variable "proxy_host" {
  type        = string
  default     = ""
  description = "The hostname of the proxy. Only needed if a proxy server is used for connecting to the AppDynamics controller."
}

variable "proxy_port" {
  type        = string
  default     = ""
  description = "The port of the proxy. Only needed if a proxy server is used for connecting to the AppDynamics controller."
}

variable "registry" {
  type    = string
  default = "mimaurer"
  description = "The registry from which the container image for the DB collector will be pulled."
}

variable "image_name" {
  type    = string
  default = "appd-dbagent"
  description = "The container image name for the DB collector image that will be pulled from the registry."
}

variable "image_tag" {
  type    = string
  default = "master"
  description = "The container image tag for the DB collector image that will be pulled from the registry."
}

variable "db_name" {
  type    = string
  description = "The name of the database. This is how the database will show up in the AppDynamics UI."
}

variable "db_type" {
  type    = string
  description = "The type of the database that we will be connecting to, for example MYSQL."
}

variable "db_hostname" {
  type    = string
  description = "The hostname of the database that we will be connecting to."
}

variable "db_port" {
  type    = string
  description = "The port of the database that we will be connecting to."
}

variable "db_username" {
  type    = string
  description = "The username of the database that we will be connecting to."
}

variable "db_password" {
  type    = string
  description = "The password of the database that we will be connecting to."
}
