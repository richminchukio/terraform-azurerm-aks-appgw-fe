# Helm AKS AppGW FrontEnd

This module uses the richminchukio/aks-appgw-fe -v='<2' helm chart. It is acceptable to use this module multiple times to deploy additional ssl terminated ingresses to your Kubernetes cluster at different ingress paths/pods. This module defaults a couple of important choices, which at this time are workarounds to [existing deficiencies in dependent charts](https://github.com/jetstack/cert-manager/issues/4613#issuecomment-982906448).

## Your main.tf

when using this module for a second time (the first time is when we call the parent module), it's best to set the following settings after using the main aks-appgw-fe module:

Copy paste the parent chart's main.tf usage of the the helm_aks_appgw_fe terraform module

```js
module "aks-appgw-fe" {
   source  = "richminchukio/aks-appgw-fe/azurerm"
   version = "1.0.0"

   arm_client_id                           = var.arm_client_id
   arm_client_secret                       = var.arm_client_secret
   arm_subscription_id                     = var.arm_subscription_id
   arm_tenant_id                           = var.arm_tenant_id
   azurerm_rg_location                     = var.azurerm_rg_location
   blue_green                              = var.blue_green
   cert_manager_crds_hack_enabled          = true
   helm_aks_appgw_fe_version               = var.helm_aks_appgw_fe_version
   helm_aks_appgw_fe_values_yaml_full_path = "./values.yaml"
   infra_prefix                            = var.infra_prefix
   k8s_version                             = var.k8s_version
   ssh_public_key                          = file("~/.ssh/id_rsa.pub")
}

module "aks-appgw-fe-subpath" {
   source  = "richminchukio/aks-appgw-fe/azurerm/helm_aks_appgw_fe"
   version = "1.0.0"

   azurerm_appgw_name                      = module.k8s_appgw_for_ingress_control.azurerm_appgw_name
   azurerm_auth_identity_resource_id       = module.k8s_appgw_for_ingress_control.azurerm_auth_identity_resource_id
   azurerm_auth_identity_client_id         = module.k8s_appgw_for_ingress_control.azurerm_auth_identity_client_id
   azurerm_public_ip_fqdn                  = azurerm_public_ip.public_ip.fqdn
   azurerm_rg_name                         = azurerm_resource_group.resource_group.name
   azurerm_subscription_id                 = data.azurerm_subscription.current.subscription_id
   blue_green                              = var.blue_green
   helm_aks_appgw_fe_version               = var.helm_aks_appgw_fe_version
   helm_aks_appgw_fe_values_yaml_full_path = "./values.standalone.yaml"
   infra_prefix                            = var.infra_prefix
}
```

## your `./values.standalone.yaml`

Get the values files, and amend it with the following yaml, and save as a new chart values.yaml file.

```yaml
######################################################################################################
# values.standalone.patch.yaml
# https://raw.githubusercontent.com/richminchukio/helm-aks-appgw-fe/main/values.standalone.patch.yaml

aad-pod-identity:
  enabled: false # disable the aad-pod-identity chart
cert-manager:
  enabled: false # disable the cert-manager chart
ingress-azure:
  enabled: false # disable the ingress-azure chart

issuer:
  enabled: false # disable the recreation of the cert-manager.io/Issuer resource:

ingress:
  path: /subpath # set the new ingress path:
```

or otherwise, take your existing values.yaml, and merge it with the `values.standalone.patch.yaml`

```sh
curl https://raw.githubusercontent.com/richminchukio/helm-aks-appgw-fe/main/values.standalone.patch.yaml |\
   yq eval-all '. as $item ireduce ({}; . * $item )' values.yaml - > values.standalone.yaml
```