data "azurerm_subscription" "current" {}

#####################################################################################################
# Resource Group and Networking

resource "azurerm_resource_group" "resource_group" {
   name     = "${var.infra_prefix}_rg"
   location = var.azurerm_rg_location
}

resource "azurerm_virtual_network" "virtual_network" {
   depends_on          = [ azurerm_resource_group.resource_group ]
   name                = "${var.infra_prefix}_vn"
   resource_group_name = azurerm_resource_group.resource_group.name
   location            = azurerm_resource_group.resource_group.location
   address_space       = [ "10.254.0.0/16" ]
}

resource "azurerm_subnet" "frontend" {
   depends_on           = [
                             azurerm_resource_group.resource_group,
                             azurerm_virtual_network.virtual_network
                          ]
   name                 = "${var.infra_prefix}_fe"
   resource_group_name  = azurerm_resource_group.resource_group.name
   virtual_network_name = azurerm_virtual_network.virtual_network.name
   address_prefixes     = ["10.254.0.0/24"]
}

resource "azurerm_subnet" "backend" {
   depends_on           = [
                             azurerm_virtual_network.virtual_network, 
                             azurerm_resource_group.resource_group
                          ]
   name                 = "${var.infra_prefix}_be"
   resource_group_name  = azurerm_resource_group.resource_group.name
   virtual_network_name = azurerm_virtual_network.virtual_network.name
   address_prefixes     = [ "10.254.2.0/24" ]
}

resource "azurerm_public_ip" "public_ip" {
   depends_on          = [ azurerm_resource_group.resource_group ]
   name                = "${var.infra_prefix}_ip"
   resource_group_name = azurerm_resource_group.resource_group.name
   location            = azurerm_resource_group.resource_group.location
   domain_name_label   = "${replace(var.infra_prefix, "_", "-")}-ip-${replace(var.blue_green, "_", "-")}"
   allocation_method   = "Static"
   sku                 = "Standard"
}

#####################################################################################################
# aks/appgw

module "k8s_appgw_for_ingress_control" {
   depends_on      = [
                        azurerm_resource_group.resource_group,
                        azurerm_virtual_network.virtual_network,
                        azurerm_subnet.frontend,
                        azurerm_public_ip.public_ip
                     ]
   source          = "./modules/k8s_appgw_for_ingress_control"

   # Vars
   azurerm_public_ip_id       = azurerm_public_ip.public_ip.id
   azurerm_subnet_frontend_id = azurerm_subnet.frontend.id
   azurerm_subnet_backend_id  = azurerm_subnet.backend.id
   azurerm_rg_name            = azurerm_resource_group.resource_group.name
   azurerm_rg_location        = azurerm_resource_group.resource_group.location
   azurerm_subscription_id    = data.azurerm_subscription.current.subscription_id
   azurerm_vn_name            = azurerm_virtual_network.virtual_network.name
   blue_green                 = var.blue_green
   infra_prefix               = var.infra_prefix
   k8s_version                = var.k8s_version
   ssh_public_key             = var.ssh_public_key
}

module "kube_config_bootstrap_sh" {
   depends_on   = [ module.k8s_appgw_for_ingress_control ]
   source       =  "./modules/kube_config_bootstrap_sh"

   # Shell scripts to prepare for deploying helm charts
   get_kubectl_sh              = module.k8s_appgw_for_ingress_control.get_kubectl_sh
   get_kube_config_sh          = module.k8s_appgw_for_ingress_control.get_kube_config_sh
   set_kube_current_context_sh = module.k8s_appgw_for_ingress_control.set_kube_current_context_sh
}

module "aks_appgw_fe" {
   depends_on = [ module.kube_config_bootstrap_sh ]
   source     = "./modules/helm_aks_appgw_fe"

   # Chart versions and chart values
   azurerm_appgw_name                            = module.k8s_appgw_for_ingress_control.azurerm_appgw_name
   azurerm_auth_identity_resource_id             = module.k8s_appgw_for_ingress_control.azurerm_auth_identity_resource_id
   azurerm_auth_identity_client_id               = module.k8s_appgw_for_ingress_control.azurerm_auth_identity_client_id
   azurerm_public_ip_fqdn                        = azurerm_public_ip.public_ip.fqdn
   azurerm_rg_name                               = azurerm_resource_group.resource_group.name
   azurerm_subscription_id                       = data.azurerm_subscription.current.subscription_id
   helm_aks_appgw_fe_version                     = var.helm_aks_appgw_fe_version
   helm_aks_appgw_fe_values_yaml_full_path       = var.helm_aks_appgw_fe_values_yaml_full_path
}

output "ip_address" {
   value       = azurerm_public_ip.public_ip.ip_address
   description = "The frontend IP address of your appgw"
}

output "fqdn" {
   value       = azurerm_public_ip.public_ip.fqdn
   description = "The frontend DNS name of your appgw"
}