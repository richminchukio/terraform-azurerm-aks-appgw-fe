variable "azurerm_appgw_name" {
   type = string
   description = "The name of the appgw"
}

variable "azurerm_auth_identity_resource_id" {
   type = string
   description = "The user assigned identity object id created by the kubernetes cluster"
}

variable "azurerm_auth_identity_client_id" {
   type = string
   description = "The user assigned identity client id created by the kubernetes cluster"
}

variable "azurerm_public_ip_fqdn" {
   type = string
   description = "The DNS name of your public IP address"
}

variable "azurerm_rg_name" {
   type = string
   description = "AzureRM resource group name."
}

variable "azurerm_subscription_id" {
   type = string
   description = "Azurerm subscription id."
}

variable "blue_green" {
   type = string
   description = "Which infrastructure to operate terraform against ('blue' or 'green')"
   default = "blue"
}

variable "cert_manager_startupapicheck_enabled" {
   type = string
   description = "cert manager does not start without issues, so disable by default"
   default = "false"
}

variable "helm_aks_appgw_fe_version" {
   type = string
   description = "the richminchukio/aks-appgw-fe chart version"
}

variable "image_repository" {
   type = string
   description = "The default image repository to use for the fe container"
   default = "httpd"
}

variable "image_tag" {
   type = string
   description = "The default image tag to use for the fe container"
   default = "latest"
}

variable "infra_prefix" {
   type = string
   description = "ie 'tf_my_thing'"
}

variable "issuer_enabled" {
   type = string
   description = "If you want to use the richminchukio/aks-appgw-fe chart twice, do not recreate the issuer."
   default = "true"
}

variable "values_yaml_full_path" {
   type = string
   description = "The path to an optional values_yaml"
}