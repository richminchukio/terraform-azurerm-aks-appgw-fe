variable "dns_zone_a_record_ttl" {
   type        = string
   description = "The Time To Live (TTL) of the DNS record in seconds."
}

variable "dns_zone_domain_name" {
   type        = string
   description = "The name of the DNS Zone. Must be a valid domain name."
}

variable "dns_zone_public_ip_id" {
   type        = string
   description = "The Azure resource id of the target object."
}

variable "dns_zone_resource_group_name" {
   type        = string
   description = "Specifies the resource group where the DNS Zone (parent resource) exists. Changing this forces a new resource to be created."
}
