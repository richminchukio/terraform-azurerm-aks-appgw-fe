variable "appgw_subscription_id" {
   type = string
   description = "The subscription id for the appgw ingress"
   default = ""
}

variable "appgw_resource_group_name" {
   type = string
   description = "The name of the resource group containing both the appgw and k8s cluster"
   default = ""
}

variable "appgw_name" {
   type = string
   description = "The name of the appgw"
   default = ""
}

variable "arm_auth_identity_resource_id" {
   type = string
   description = "The user assigned identity object id created by the kubernetes cluster"
   default = ""
}

variable "arm_auth_identity_client_id" {
   type = string
   description = "The user assigned identity client id created by the kubernetes cluster"
   default = ""
}

variable "blue_green" {
   type = string
   description = "Which infrastructure to operate terraform against ('blue' or 'green')"
   default = ""
}

variable "helm_aad_pod_identity_version" {
   type = string
   description = "the chart version"
   default = "2.0.2"
}

variable "helm_ingress_azure_version" {
   type = string
   description = "the chart version"
   default = "1.2.0"
}

variable "helm_cert_manager_version" {
   type = string
   description = "the chart version"
   default = "v1.0.1"
}

variable "infra_prefix" {
   type = string
   description = "ie 'tf_my_thing'"
   default = "tf"
}