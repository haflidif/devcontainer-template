# Terraform Outputs
# Define outputs for your Terraform configuration

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.example.name
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = azurerm_resource_group.example.location
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.example.name
}

output "storage_account_primary_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.example.primary_blob_endpoint
}
