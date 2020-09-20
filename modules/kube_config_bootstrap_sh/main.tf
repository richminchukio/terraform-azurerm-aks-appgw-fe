resource "null_resource" "sh_az_aks_bootstrap_helm" {
   triggers   = {
      always_run = "${timestamp()}"
   }
   
   provisioner "local-exec" {
      command    = <<EOT
         ${var.get_kubectl_sh}
         ${var.get_kube_config_sh}
         ${var.set_kube_current_context_sh}
      EOT
   }
}