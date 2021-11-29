variable "arm_client_id" {
   type = string
   description = "For CI in Azure DevOps Pipelines. TF AzureRM Provider does not support using the Azure CLI"
   default = ""
}

variable "arm_client_secret" {
   type = string
   description = "For CI in Azure DevOps Pipelines. TF AzureRM Provider does not support using the Azure CLI"
   default = ""
}

variable "arm_kubernetes_config_path" {
   type = string
   description = "For CI in Azure DevOps Pipelines. Helm needs to explicitly know where the ~/.kube/config is."
   default = ""
}

variable "arm_subscription_id" {
   type = string
   description = "For CI in Azure DevOps Pipelines. TF AzureRM Provider does not support using the Azure CLI"
   default = ""
}

variable "arm_tenant_id" {
   type = string
   description = "For CI in Azure DevOps Pipelines. TF AzureRM Provider does not support using the Azure CLI"
   default = ""
}

variable "arm_use_msi" {
   type = string
   description = "For CI in Azure DevOps Pipelines. TF AzureRM Provider does not support using the Azure CLI"
   default = ""
}

variable "azurerm_rg_location" {
   type = string
   description = "AzureRM resource group location. IE: eastus"
}

variable "blue_green" {
   type = string
   description = "Which infrastructure to operate terraform against ('blue' or 'green')"
   default = "blue"
}

variable "helm_aks_appgw_fe_version" {
   type = string
   description = "the richminchukio/aks-appgw-fe chart version"
}

variable "infra_prefix" {
   type = string
   description = "ie 'tf_my_thing'"
   default = "tf"
}

variable "image_repository" {
   type = string
   description = "The default image repository to use for the fe container"
   default = "httpd"
}

variable "image_tag" {
   type = string
   description = "The default image tag to use for the fe container"
   default = "latest"
}

variable "k8s_version" {
   type = string
   description = "Which Kuberentes preview aks version to create"
   default = ""
}

variable "ssh_public_key" {
   type = string
   description = "Your public key at ~/.ssh/id_rsa.pub. IE: `export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)`"
}

variable "values_yaml_full_path" {
   type = string
   description = "An optional values.yaml file for further control of the richminchukio/aks-appgw-fe helm chart"
   default = "values.yaml"
}
