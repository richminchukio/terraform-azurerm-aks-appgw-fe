######################################################################################################
# Azure Application Gateway setup

locals {
   backend_address_pool_name      = "${var.azurerm_vn_name}_beap"
   frontend_port_name             = "${var.azurerm_vn_name}_feport"
   frontend_ip_configuration_name = "${var.azurerm_vn_name}_feip"
   http_setting_name              = "${var.azurerm_vn_name}_be-htst"
   listener_name                  = "${var.azurerm_vn_name}_httplstn"
   request_routing_rule_name      = "${var.azurerm_vn_name}_rqrt"
   redirect_configuration_name    = "${var.azurerm_vn_name}_rdrcfg"
}

resource "azurerm_application_gateway" "appgw" {
   lifecycle {
      ignore_changes = [
         # This is an appgw ingress controller module. 
         # These attributes change upon deployment of the ingress chart, so we ignore their changes and let the ingress controller maintian the appgw.
         tags["last-updated-by-k8s-ingress"],
         tags["managed-by-k8s-ingress"],
         backend_address_pool[0].name,
         backend_http_settings,
         http_listener[0].name,
         probe,
         request_routing_rule
      ]
   }

   name                = "${var.infra_prefix}_appgw_${var.blue_green}"
   resource_group_name = var.azurerm_rg_name
   location            = var.azurerm_rg_location
   tags = {
      last-updated-by-k8s-ingress = ""
      managed-by-k8s-ingress = ""
   }

   sku {
      name     = "Standard_v2"
      tier     = "Standard_v2"
      capacity = 1
   }

   gateway_ip_configuration {
      name      = "${var.infra_prefix}_ip_conf_${var.blue_green}"
      subnet_id = var.azurerm_subnet_frontend_id
   }

   frontend_port {
      name = "${local.frontend_port_name}_${var.blue_green}"
      port = 80
   }

   frontend_ip_configuration {
      name                 = "${local.frontend_ip_configuration_name}_${var.blue_green}"
      public_ip_address_id = var.azurerm_public_ip_id
   }

   backend_address_pool {
      name = "${local.backend_address_pool_name}_${var.blue_green}"
   }

   backend_http_settings {
      name                  = "${local.http_setting_name}_${var.blue_green}"
      cookie_based_affinity = "Enabled"
      affinity_cookie_name  = "ApplicationGatewayAffinity"
      path                  = "/"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 1
   }

   http_listener {
      name                           = "${local.listener_name}_${var.blue_green}"
      frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}_${var.blue_green}"
      frontend_port_name             = "${local.frontend_port_name}_${var.blue_green}"
      protocol                       = "Http"
   }

   request_routing_rule {
      name                       = "${local.request_routing_rule_name}_${var.blue_green}"
      rule_type                  = "Basic"
      http_listener_name         = "${local.listener_name}_${var.blue_green}"
      backend_address_pool_name  = "${local.backend_address_pool_name}_${var.blue_green}"
      backend_http_settings_name = "${local.http_setting_name}_${var.blue_green}"
   }
}

######################################################################################################
# Azure Kubernetes Service setup

resource "azurerm_kubernetes_cluster" "aks" {
   name                = "${var.infra_prefix}_aks_${var.blue_green}"
   location            = var.azurerm_rg_location
   resource_group_name = var.azurerm_rg_name
   dns_prefix          = "acctestagent1"
   kubernetes_version  = var.k8s_version

   linux_profile {
      admin_username = "${var.infra_prefix}_aks_${var.blue_green}"
      ssh_key {
         key_data = var.ssh_public_key
      }
   }

   default_node_pool {
      name                = "default"
      node_count          = 1
      vm_size             = "Standard_B2s"
      os_disk_size_gb     = 30
      type                = "VirtualMachineScaleSets"
      enable_auto_scaling = false
      vnet_subnet_id      = var.azurerm_subnet_backend_id
   }

   role_based_access_control {
      enabled = true

      azure_active_directory {
         managed = true
      }
   }

   # Managed Service Identity. IE: No hard coded Service Principal Secret
   identity {
     type = "SystemAssigned"
   }

   ## Need advanced networking for ingress support
   ## This is supported by AGIC or Azure's Application Gateway Ingress Controller.
   ## https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples/kubernetes/advanced-networking
   ## https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-install-new
   network_profile {
      network_plugin = "azure"
   }

   tags = {
      Environment = "Production"
   }
}

######################################################################################################
# Managed Identity

# grant Reader to the managed identity on the resource group
resource "azurerm_role_assignment" "user_assigned_identity_reader" {
   depends_on           = [azurerm_kubernetes_cluster.aks]
   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
   role_definition_name = "Reader"
   scope                = "/subscriptions/${var.azurerm_subscription_id}/resourceGroups/${var.azurerm_rg_name}"
}

# grant Contributor to the managed identity on the application gateway for the purposes of allowing AGIC to modify the gateway on the fly
resource "azurerm_role_assignment" "user_assigned_identity_contributor" {
   depends_on           = [azurerm_kubernetes_cluster.aks]
   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
   role_definition_name = "Contributor"
   scope                = "/subscriptions/${var.azurerm_subscription_id}/resourceGroups/${var.azurerm_rg_name}/providers/Microsoft.Network/applicationGateways/${azurerm_application_gateway.appgw.name}"
}

# setup msi (managed identity) azure pod identity - https://github.com/Azure/aad-pod-identity - taken from ./hack/role-assignment.sh
# grant Managed Identity Operator to the aks managed identity
resource "azurerm_role_assignment" "user_assigned_identity_managed_identity_operator" {
   depends_on           = [azurerm_kubernetes_cluster.aks]
   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
   role_definition_name = "Managed Identity Operator"
   scope                = "/subscriptions/${var.azurerm_subscription_id}/resourcegroups/MC_${var.azurerm_rg_name}_${azurerm_kubernetes_cluster.aks.name}_${azurerm_kubernetes_cluster.aks.location}"
}

# grant Virtual Machine Contributor to the aks managed identity
resource "azurerm_role_assignment" "user_assigned_identity_virtual_machine_contributor" {
   depends_on           = [azurerm_kubernetes_cluster.aks]
   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
   role_definition_name = "Virtual Machine Contributor"
   scope                = "/subscriptions/${var.azurerm_subscription_id}/resourcegroups/MC_${var.azurerm_rg_name}_${azurerm_kubernetes_cluster.aks.name}_${azurerm_kubernetes_cluster.aks.location}"
}