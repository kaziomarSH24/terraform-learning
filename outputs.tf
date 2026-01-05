output "resource_group_name" {
  value = azurerm_resource_group.my_rg.name
}

output "public_ip_address" {
  value = azurerm_public_ip.my_public_ip.ip_address
}

output "admin_username" {
  value = var.admin_username
}