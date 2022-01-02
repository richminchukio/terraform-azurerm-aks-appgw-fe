# Azure RM DNS Zone

If you care to use the azurerm provider baked into this terraform module for the purposes of creating a DNS Zone for your domain name, this module is for you.

I didn't feel like duplicating the provider code in my own IAC repo to get this done, so I'm adding this sub module!

## ADD to variables.tf.json

```js
"dns_zone_a_record_ttl": {
   "default": 3600
},
"dns_zone_domain_name": {
   "default": ""
},
"dns_zone_public_ip_id": {
   "default": ""
},
"dns_zone_resource_group_name": {
   "default": ""
}
```

## ADD to main.tf

```js
module "aks-appgw-fe_azurerm_dns_zone" {
   source  = "richminchukio/aks-appgw-fe/azurerm//modules/azurerm_dns_zone"
   version = "1.0.0"

   dns_zone_a_record_ttl        = var.dns_zone_a_record_ttl
   dns_zone_domain_name         = var.dns_zone_domain_name
   dns_zone_public_ip_id        = var.dns_zone_public_ip_id
   dns_zone_resource_group_name = var.dns_zone_resource_group_name
}
```