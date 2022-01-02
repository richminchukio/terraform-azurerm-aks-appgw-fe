#############################################################################################################################################
# DNS Zones. IE: Name 

resource "azurerm_dns_zone" "dns_zone" {
   name                = var.dns_zone_domain_name
   resource_group_name = var.dns_zone_resource_group_name
}

resource "azurerm_dns_a_record" "a_record" {
   name                = "@"
   zone_name           = azurerm_dns_zone.dns_zone.name
   resource_group_name = var.dns_zone_resource_group_name
   ttl                 = var.dns_zone_a_record_ttl
   target_resource_id  = var.dns_zone_public_ip_id
}

output "dns_zone_id" {
  value = azurerm_dns_zone.dns_zone.id
}

output "dns_zone_name_servers" {
  value = azurerm_dns_zone.dns_zone.name_servers
}