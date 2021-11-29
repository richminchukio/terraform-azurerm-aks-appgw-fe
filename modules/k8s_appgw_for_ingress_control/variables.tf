variable "azurerm_public_ip_id" {
   type = string
   description = "AzureRM public ip id. IE: eastus"
}

variable "azurerm_rg_location" {
   type = string
   description = "AzureRM resource group location. IE: eastus"
}

variable "azurerm_rg_name" {
   type = string
   description = "AzureRM resource group name."
}

variable "azurerm_subnet_frontend_id" {
   type = string
   description = "AzureRM subnet frontend id."
}

variable "azurerm_subnet_backend_id" {
   type = string
   description = "AzureRM subnet backend id."
}

variable "azurerm_subscription_id" {
   type = string
   description = "Azurerm subscription id."
}

variable "azurerm_vn_name" {
   type = string
   description = "Azure virtual network name."
}

variable "blue_green" {
   type = string
   description = "Which infrastructure to operate terraform against ('blue' or 'green')"
   default = "blue"
}

variable "infra_prefix" {
   type = string
   description = "A prefix for your terraformed resources: ie 'tf_my_thing'"
   default = ""
}

variable "k8s_version" {
   type = string
   description = "Which Kuberentes preview aks version to create"
   default = ""
}

variable "ssh_public_key" {
   type = string
   description = "Your public key at ~/.ssh/id_rsa.pub"
}