variable "blue_green" {
   type = string
   description = "Which infrastructure to operate terraform against ('blue' or 'green')"
   default = "blue"
}

variable "infra_prefix" {
   type = string
   description = "A prefix for your terraformed resources: ie 'tf_my_thing'"
   default = "tf"
}

variable "k8s_version" {
   type = string
   description = "Which Kuberentes preview aks version to create"
   default = "1.18.6"
}

variable "location" {
   type = string
   description = "Azure RM resource location. IE: eastus"
   default = "eastus"
}

variable "ssh_public_key" {
   type = string
   description = "Your public key at ~/.ssh/id_rsa.pub"
}

variable "subscription_id" {
   type = string
   description = "Your Azure Subscription id. Retrieved from `az login` command"
   default = ""
}