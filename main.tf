data "azurerm_subscription" "current" {}

module "k8s_appgw_for_ingress_control" {
   source     =  "./modules/k8s_appgw_for_ingress_control"

   # Vars
   blue_green      = var.blue_green
   infra_prefix    = var.infra_prefix
   k8s_version     = var.k8s_version
   location        = var.location
   ssh_public_key  = var.ssh_public_key
   subscription_id = data.azurerm_subscription.current.subscription_id
}

module "kube_config_bootstrap_sh" {
   source     =  "./modules/kube_config_bootstrap_sh"

   # Shell scripts to prepare for deploying helm charts
   get_kubectl_sh              = module.k8s_appgw_for_ingress_control.get_kubectl_sh
   get_kube_config_sh          = module.k8s_appgw_for_ingress_control.get_kube_config_sh
   set_kube_current_context_sh = module.k8s_appgw_for_ingress_control.set_kube_current_context_sh
}

module "k8s_ingress_charts" {
   depends_on = [module.kube_config_bootstrap_sh]
   source     = "./modules/k8s_ingress_charts"

   # Chart versions and chart values
   appgw_subscription_id         = data.azurerm_subscription.current.subscription_id
   appgw_resource_group_name     = module.k8s_appgw_for_ingress_control.appgw_resource_group_name
   appgw_name                    = module.k8s_appgw_for_ingress_control.appgw_name
   arm_auth_identity_resource_id = module.k8s_appgw_for_ingress_control.arm_auth_identity_resource_id
   arm_auth_identity_client_id   = module.k8s_appgw_for_ingress_control.arm_auth_identity_client_id
   blue_green                    = var.blue_green
   helm_aad_pod_identity_version = var.helm_aad_pod_identity_version
   helm_ingress_azure_version    = var.helm_ingress_azure_version
   helm_cert_manager_version     = var.helm_cert_manager_version
   infra_prefix                  = var.infra_prefix
}

output "public_ip" {
   value       = module.k8s_appgw_for_ingress_control.ip_address
   description = "The frontend IP address of your appgw"
}