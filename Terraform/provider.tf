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


}
