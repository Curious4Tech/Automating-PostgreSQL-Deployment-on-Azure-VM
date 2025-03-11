# Output Values
output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "vm_username" {
  value = var.vm_username
}