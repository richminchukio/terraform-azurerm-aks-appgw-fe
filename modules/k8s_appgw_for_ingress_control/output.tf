output "get_kubectl_sh" {
   value       = "az aks install-cli --client-version ${azurerm_kubernetes_cluster.aks.kubernetes_version}"
   description = "Command to retrieve the correct version of kubectl"
}

output "get_kube_config_sh" {
   value       = "az aks get-credentials --resource-group ${azurerm_resource_group.resource_group.name} --name ${azurerm_kubernetes_cluster.aks.name} --overwrite-existing --admin"
   description = "Command to retrieve the cluster kube config"
}

output "set_kube_current_context_sh" {
   value       = "kubectl config use-context ${azurerm_kubernetes_cluster.aks.name}-admin"
   description = "Command to set the kube config current-context"
}

output "appgw_resource_group_name" {
   value       = azurerm_resource_group.resource_group.name
   description = "The resource group name which contains the appgw"
}

output "appgw_name" {
   value       = azurerm_application_gateway.appgw.name
   description = "The appgw name"
}

output "arm_auth_identity_resource_id" {
   value       = azurerm_kubernetes_cluster.aks.kubelet_identity.0.user_assigned_identity_id
   description = "The user assigned identity's object id - created by/for the azure kubernetes cluster"
   sensitive   = true
}

output "arm_auth_identity_client_id" {
   value       = azurerm_kubernetes_cluster.aks.kubelet_identity.0.client_id
   description = "The user assigned identity's client id - created by/for the azure kubernetes cluster"
   sensitive   = true
}

output "ip_address" {
   value       = azurerm_public_ip.public_ip.ip_address
   description = "The frontend IP address of your appgw"
}