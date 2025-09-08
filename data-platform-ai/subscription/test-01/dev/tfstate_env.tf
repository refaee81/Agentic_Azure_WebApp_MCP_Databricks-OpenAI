# Create the terraform.tfstate file in a unique path based of of the environment_name
# This needs to be done in each environment.  The Azure Blob storage is done at the blueprint level

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-dexxx-xxxxxx-xxxxxxxxx-x-cc-01"
    storage_account_name = "sadevxxx-xxxxxx-xxxxxxxxx-xqz"
    container_name       = "tfstate-dpe"
    key                  = "daptest.dev.ai.terraform.tfstate"
    use_azuread_auth     = true # when authenticating using Azure AD Authentication
  }
}