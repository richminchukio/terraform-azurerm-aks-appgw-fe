#############################################################################################################################################
# HELM - richminchukio/aks-appgw-fe: aad-pod-identity, ingress-azure, cert-manager

# Create Cert-Manager CRDs until Cert-Manager chart supports the CRDs folder standard of helm3. more info [here](https://github.com/jetstack/cert-manager/issues/4613#issuecomment-982906448)
resource "null_resource" "sh_kubectl_apply_crds_hack" {
   count     = var.cert_manager_crds_hack_enabled ? 1 : 0
   triggers  = { always_run = "${timestamp()}" }
   
   provisioner "local-exec" {
      command  = <<EOT
         kubectl apply -f ${var.cert_manager_crds_hack_url}
      EOT
   }
}

resource "helm_release" "aks_appgw_fe" {
   depends_on      = [ null_resource.sh_kubectl_apply_crds_hack ]
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
      "${ fileexists(var.helm_aks_appgw_fe_values_yaml_full_path) ? file(var.helm_aks_appgw_fe_values_yaml_full_path) : null }"
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
      name  = "ingress.host"
      value = var.helm_ingress_host != "" ? var.helm_ingress_host : var.azurerm_public_ip_fqdn
   }
}