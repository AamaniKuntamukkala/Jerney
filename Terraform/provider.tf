terraform {
  required_version = ">= 1.5.0"



  # Uncomment and configure for remote state (recommended for teams)
  # backend "azurerm" {
  #   resource_group_name   = "tfstate-rg"
  #   storage_account_name  = "tfstateaccount"
  #   container_name        = "tfstate"
  #   key                   = "aks/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}

  # Option 1: Use environment variables (recommended)
  # Terraform automatically picks up ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID

  # Option 2: Pass via variables (less secure, but explicit)
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  default_tags {
    tags = {
      Project     = "Journey"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
