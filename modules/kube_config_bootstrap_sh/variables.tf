variable "get_kubectl_sh" {
   type = string
   description = "Command to retrieve the correct version of kubectl"
}

variable "get_kube_config_sh" {
   type = string
   description = "Command to retrieve the cluster kube config"
}

variable "set_kube_current_context_sh" {
   type = string
   description = "Command to set the kube config current-context"
}