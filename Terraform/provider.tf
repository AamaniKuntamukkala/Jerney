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


  default_tags {
    tags = {
      Project     = "Journey"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
