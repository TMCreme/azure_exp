output "public_ip" {
  description = "Public IP Associated with the Instance"
  value       = azurerm_public_ip.staticpublicip.ip_address
}


