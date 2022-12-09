output "nodes_dns_name" {
  description = "The name of the instances provisioned"
  value       = azurerm_public_ip.public-ip.*.fqdn
}