# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Resource Groups
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# This file contains the Terraform configuration for the resource containers and role assignments for the resource groups used in the current environment.
#
# Resources Deployed
#   * `azurerm_resource_group.tf`      : Resource group for Terraform-related resources (e.g., Terraform state files).
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Resource Groups ─> Terraform
#   * Container for resources related to the storage and management of Terraform state files
resource "azurerm_resource_group" "tf" {
  name     = "rg-${var.environment}-dap-${var.application}-tf-${var.region}-01"
  location = var.region_long
  tags     = local.tags_dpe
}

# Resource Groups ─> Networking
#   * Container for resources related to networking (e.g. PEP, RT, NSG, etc.)
resource "azurerm_resource_group" "network" {
  name     = "rg-${var.environment}-dap-${var.application}-nw-${var.region}-01"
  location = var.region_long
  tags     = local.tags_dpe
}
# RG - rg-dev-dap-ai-service-cc-01
#   * for deploying dev openAI instance
resource "azurerm_resource_group" "dev_openAI" {
  name     = "rg-${var.environment}-dap-${var.application}-service-${var.region}-01"
  location = var.region_long
  tags     = merge(local.tags_dpe, {"technicalLead": "Rxxx-xxxxxx-xxxxxxxxx-x"})
}

# RG - rg-dev-dap-ai-sec-cc-01
resource "azurerm_resource_group" "sec_ai" {
  name     = "rg-${var.environment}-dap-${var.application}-sec-${var.region}-01"
  location = var.region_long
  tags     = merge(local.tags_dpe, {"technicalLead": "Rxxx-xxxxxx-xxxxxxxxx-xa"})
}

# RG - rg-dev-dap-ai-storage-cc-01
resource "azurerm_resource_group" "storage_ai" {
  name     = "rg-${var.environment}-dap-${var.application}-storage-${var.region}-01"
  location = var.region_long
  tags     = merge(local.tags_dpe, {"technicalLead": "xxx-xxxxxx-xxxxxxxxx-xa"})
}

# RG - rg-dev-dap-ai-tf-cc-01
# └── Management Locks
#     └── Management Lock: `CanNotDelete` Resource group#         
resource "azurerm_management_lock" "rg_lock_01" {
  name       = "${azurerm_resource_group.tf.name}-lock-01"
  scope      = azurerm_resource_group.tf.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}

# RG - rg-dev-dap-ai-nw-cc-01
# └── Management Locks
#     └── Management Lock: `CanNotDelete` Resource group#         
resource "azurerm_management_lock" "rg_lock_02" {
  name       = "${azurerm_resource_group.network.name}-lock-01"
  scope      = azurerm_resource_group.network.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}