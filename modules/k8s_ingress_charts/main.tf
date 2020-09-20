#############################################################################################################################################
# HELM - aad-pod-identity, ingress-azure, cert-manager

resource "helm_release" "aad_pod_identity" {
   depends_on      = []
   name            = "${replace(var.infra_prefix, "_", "-")}-aad-pod-identity-${replace(var.blue_green, "_", "-")}"
   namespace       = "default"
   repository      = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
   chart           = "aad-pod-identity"
   version         = var.helm_aad_pod_identity_version
   force_update    = true
   recreate_pods   = true
   cleanup_on_fail = true
   atomic          = true
   wait            = true
   replace         = true
}

resource "helm_release" "ingress" {
   depends_on      = [helm_release.aad_pod_identity]
   name            = "${replace(var.infra_prefix, "_", "-")}-agic-${replace(var.blue_green, "_", "-")}"
   namespace       = "default"
   repository      = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package"
   chart           = "ingress-azure"
   version         = var.helm_ingress_azure_version
   force_update    = true
   recreate_pods   = true
   cleanup_on_fail = true
   atomic          = true
   wait            = true
   replace         = true

   set {
      type  = "string"
      name  = "appgw.subscriptionId"
      value = var.appgw_subscription_id 
   }

   set {
      type  = "string"
      name  = "appgw.resourceGroup"
      value = var.appgw_resource_group_name
   }

   set {
      type  = "string"
      name  = "appgw.name"
      value = var.appgw_name
   }

   set {
      type  = "string"
      name  = "appgw.usePrivateIP"
      value = "false"
   }

   set {
      type  = "string"
      name  = "appgw.shared"
      value = "false"
   }

   set {
      type  = "string"
      name  = "armAuth.type"
      value = "aadPodIdentity" 
   }

   set {
      type  = "string"
      name  = "armAuth.identityResourceID"
      value = var.arm_auth_identity_resource_id
   }

   set {
      type  = "string"
      name  = "armAuth.identityClientID"
      value = var.arm_auth_identity_client_id
   }

   set {
      type  = "string"
      name  = "rbac.enabled"
      value = "true"
   }
}

resource "helm_release" "lets_encrypt" {
   depends_on      = []
   name            = "${replace(var.infra_prefix, "_", "-")}-cert-manager-${replace(var.blue_green, "_", "-")}"
   namespace       = "default"
   repository      = "https://charts.jetstack.io/"
   chart           = "cert-manager"
   version         = var.helm_cert_manager_version
   force_update    = true
   recreate_pods   = true
   cleanup_on_fail = true
   atomic          = true
   wait            = true
   replace         = true
   
   set {
      type = "string"
      name = "installCRDs"
      value = "true"
   }
}