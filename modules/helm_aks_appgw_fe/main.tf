#############################################################################################################################################
# HELM - richminchukio/aks-appgw-fe: aad-pod-identity, ingress-azure, cert-manager

resource "helm_release" "aks_appgw_fe" {
   depends_on      = []
   name            = "tf-aks-appgw-fe"
   namespace       = "default"
   repository      = "https://raw.githubusercontent.com/richminchukio/helm-aks-appgw-fe/master"
   chart           = "aks-appgw-fe"
   version         = var.helm_aks_appgw_fe_version
   force_update    = true
   recreate_pods   = true
   cleanup_on_fail = true
   atomic          = true
   wait            = true
   replace         = true

   values = [
      fileexists(var.values_yaml_full_path) ? file(var.values_yaml_full_path) : null
   ]

   set {
      type  = "string"
      name  = "ingress-azure.appgw.subscriptionId"
      value = var.azurerm_subscription_id
   }

   set {
      type  = "string"
      name  = "ingress-azure.appgw.resourceGroup"
      value = var.azurerm_rg_name
   }

   set {
      type  = "string"
      name  = "ingress-azure.appgw.name"
      value = var.azurerm_appgw_name
   }

   set {
      type  = "string"
      name  = "ingress-azure.appgw.usePrivateIP"
      value = "false"
   }

   set {
      type  = "string"
      name  = "ingress-azure.appgw.shared"
      value = "false"
   }

   set {
      type  = "string"
      name  = "ingress-azure.armAuth.type"
      value = "aadPodIdentity"
   }

   set {
      type  = "string"
      name  = "ingress-azure.armAuth.identityResourceID"
      value = var.azurerm_auth_identity_resource_id
   }

   set {
      type  = "string"
      name  = "ingress-azure.armAuth.identityClientID"
      value = var.azurerm_auth_identity_client_id
   }

   set {
      type  = "string"
      name  = "ingress-azure.rbac.enabled"
      value = "true"
   }

   set {
      type  = "string"
      name  = "cert-manager.installCRDs"
      value = "true"
   }

   set {
      type  = "string"
      name  = "cert-manager.startupapicheck.enabled"
      value = var.cert_manager_startupapicheck_enabled
   }

   set {
      type  = "string"
      name  = "issuer.enabled"
      value = var.issuer_enabled
   }

   set {
      type  = "string"
      name  = "ingress.host"
      value = var.azurerm_public_ip_fqdn
   }

   set {
      type  = "string"
      name  = "image.repository"
      value = var.image_repository
   }

   set {
      type  = "string"
      name  = "image.tag"
      value = var.image_tag
   }
}