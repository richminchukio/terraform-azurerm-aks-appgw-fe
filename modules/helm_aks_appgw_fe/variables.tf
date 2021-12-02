variable "azurerm_appgw_name" {
   type        = string
   description = "The name of the appgw"
}

variable "azurerm_auth_identity_resource_id" {
   type        = string
   description = "The user assigned identity object id created by the kubernetes cluster"
}

variable "azurerm_auth_identity_client_id" {
   type        = string
   description = "The user assigned identity client id created by the kubernetes cluster"
}

variable "azurerm_public_ip_fqdn" {
   type        = string
   description = "The DNS name of your public IP address"
}

variable "azurerm_rg_name" {
   type        = string
   description = "AzureRM resource group name."
}

variable "azurerm_subscription_id" {
   type        = string
   description = "Azurerm subscription id."
}

variable "blue_green" {
   type        = string
   description = "Which infrastructure to operate terraform against ('blue' or 'green')"
   default     = "blue"
}

variable "cert_manager_crds_hack_enabled" {
   type        = bool
   description = "helm doesn't deploy dependant chart CRDs before the parent chart api objects. IE: cert-manager.io/Issuer manifest fails to deploy. Cert-Manager needs to support CRDs folder naming convention for helm 3, until then hack it."
   default     = false
}

variable "cert_manager_crds_hack_url" {
   type        = string
   description = "helm doesn't deploy dependant chart CRDs before the parent chart api objects. IE: cert-manager.io/Issuer manifest fails to deploy. Cert-Manager needs to support CRDs folder naming convention for helm 3, until then hack it."
   default     = "https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml"
}

variable "helm_aks_appgw_fe_version" {
   type        = string
   description = "the richminchukio/aks-appgw-fe chart version"
}

variable "helm_cert_manager_startupapicheck_enabled" {
   type        = string
   description = "cert manager does not start without issues, so disable by default"
   default     = "false"
}

variable "helm_image_repository" {
   type        = string
   description = "The default image repository to use for the fe container"
   default     = "httpd"
}

variable "helm_image_tag" {
   type        = string
   description = "The default image tag to use for the fe container"
   default     = "latest"
}

variable "helm_ingress_host" {
   type        = string
   description = "Defaults to the DNS name of your Public IP which is assigned to your Application Gateway, but otherwise in prod envs, your domain name."
   default     = ""
}

variable "helm_issuer_acme_privateKeySecretRef_name" {
   type        = string
   description = "we default the name of the secret to staging in case you want to reuse the module for prod."
   default     = "issuer-account-key-staging"
}

variable "helm_issuer_acme_server" {
   type        = string
   description = "The letsencrypt.org staging server"
   default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "helm_issuer_acme_solver0_http01_ingress_class" {
   type        = string
   description = "the solver http class"
   default     = "azure/application-gateway"
}

variable "infra_prefix" {
   type        = string
   description = "ie 'tf_my_thing'"
}

variable "helm_aks_appgw_fe_values_yaml_full_path" {
   type        = string
   description = "The path to the required values.yaml for richminchukio/aks-appgw-fe. get this file from the values file in the chart git repo, or read the README.md"
}