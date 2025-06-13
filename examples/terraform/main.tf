# Example Terraform Configuration
# This is a basic example showing how to structure a Terraform project

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    # Uncomment for AWS
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0"
    # }
    # Uncomment for GCP
    # google = {
    #   source  = "hashicorp/google"
    #   version = "~> 5.0"
    # }
  }

  # Configure your backend here
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "mystorageaccount"
  #   container_name       = "tfstate"
  #   key                  = "myproject.terraform.tfstate"
  # }

  # backend "s3" {
  #   bucket = "my-terraform-state-bucket"
  #   key    = "myproject/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Example: Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location

  tags = var.common_tags
}

# Example: Create a storage account
resource "azurerm_storage_account" "example" {
  name                     = "${var.project_name}${var.environment}sa"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.common_tags
}
