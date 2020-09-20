provider "azurerm" {
   version          = "~>2.28"
   client_id        = (var.arm_client_id != "" ? var.arm_client_id : null)
   client_secret    = (var.arm_client_secret != "" ? var.arm_client_secret : null)
   subscription_id  = (var.arm_subscription_id != "" ? var.arm_subscription_id : null)
   tenant_id        = (var.arm_tenant_id != "" ? var.arm_tenant_id : null)
   use_msi          = (var.arm_use_msi != "" ? true : null)
   features {}
}

provider "null" {
}

provider "helm" {
   kubernetes {
   }
}