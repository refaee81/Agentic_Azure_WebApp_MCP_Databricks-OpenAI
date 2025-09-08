# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Storage Account for Terraform State File
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# This file contains the Terraform configuration for the storage account used to store the Terraform state file.
#
# Resources Deployed
# * `azurerm_storage_account.tf`                  : Storage account for storing the Terraform state file.
# * `azurerm_role_assignment.sa_tf_rbac[*]`       : Role assignments for granting access to the storage account.
# * `azurerm_storage_container.tf`                : Storage container for the Terraform state file.
# * `azurerm_private_endpoint.tf_storage`         : Private endpoint for accessing the storage account securely.
# * `azurerm_management_lock.sa_tf_lock[*]`       : Management lock for protecting the storage account from accidental deletion.
# * `azurerm_management_lock.pep_tf_sa_lock[*]`   : Management lock for protecting the private endpoint from accidental deletion.
#
# Dependencies
# * azurerm_resource_group.tf                     : Resource group for the Terraform storage account.
# * data.azurerm_client_config.current            : Current Azure client configuration.
# * data.azuread_group.dp_platform_engineers_ai   : Azure AD group for platform engineers.
# * data.azurerm_private_dns_zone.sa_blob         : Private DNS zone for the storage account blob service.
# * azurerm_subnet.snet_ai_dev_pep               : Subnet for the private endpoint.
# * local.tags_dpe                                : Tags for the storage account.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Storage Account
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Random String for Terraform Storage Account Suffix
resource "random_string" "sa_tf_suffix" {
  length  = 8
  numeric = true
}

# Terraform Storage Account
#   * Storage account for storing the Terraform state file.
resource "azurerm_storage_account" "tf" {
  name                            = "sa${var.environment}${var.application}tf${random_string.sa_tf_suffix.result}"
  resource_group_name             = azurerm_resource_group.tf.name
  location                        = azurerm_resource_group.tf.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  allow_nested_items_to_be_public = false
  tags                            = local.tags_dpe
  public_network_access_enabled   = false
  shared_access_key_enabled       = false

  blob_properties {
    delete_retention_policy {
      days = 31
    }
    container_delete_retention_policy {
      days = 31
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  network_rules {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
    bypass                     = ["Logging", "Metrics", "AzureServices"]
    private_link_access {
      endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/StorageDataScanner"
      endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
    }
  }

  sas_policy {
    expiration_action = "Log"
    expiration_period = "0.12:00:00"
  }

}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Role Assignments
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform Storage Account
# └── Role Assignments
#     ├── Role Assignment → Grant `Contributor` role to `sp-dap-terraform-<env>` service principal on the Terraform Storage Account
#     |     * Enables Terraform to manage the storage account and its resources
#     ├── Role Assignment → Grant `Storage Blob Data Owner` to `sp-dap-terraform-<env>` service principal on the Terraform Storage Account
#     |     * Enables Terraform to manage the storage account containers and the terraform state file contained within.
#     └── Role Assignment → Grant `Storage Blob Data Contributor` to `dp-platform-engineers-ai` group on the Terraform Storage Account
#           * Enables platform engineers to view the storage account containers and the terraform state file contained within.
resource "azurerm_role_assignment" "sa_tf_01" {
  scope                = azurerm_storage_account.tf.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "sa_tf_02" {
  scope                = azurerm_storage_account.tf.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "sa_tf_03" {
  scope                = azurerm_storage_account.tf.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_group.dp_platform_engineers_ai.object_id
}

resource "azurerm_role_assignment" "sa_tf_04" {
  scope                = azurerm_storage_account.tf.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.dp_platform_engineers_ai.object_id
}
 
resource "azurerm_role_assignment" "sa_tf_05" {
  scope                = azurerm_storage_account.tf.id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = data.azuread_group.dp_platform_engineers_ai.object_id
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Private Endpoints
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform Storage Account
# └── Private Endpoints
#     └── Private Endpoint `pep-<env>-dap-ai-tf-cc-01` (Blob)
#           * Private Endpoint used to access the Terraform state files stored in the Storage Account
resource "azurerm_private_endpoint" "tf_storage" {

  name                = "pep-${var.environment}-dap-${var.application}-tf-${var.region}-01"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  subnet_id           = azurerm_subnet.snet_ai_dev_pep.id
  tags                = local.tags_dpe

  private_service_connection {
    name                           = "pl-${var.environment}-dap-${var.application}-tf-${var.region}-01"
    private_connection_resource_id = azurerm_storage_account.tf.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
    request_message                = null
  }

  private_dns_zone_group {
    name                 = data.azurerm_private_dns_zone.sa_blob.name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.sa_blob.id]
  }
}

# Terraform Storage Account
# └── Storage Containers
#     └── Storage Container `tfstate-dpe`
#           * Storage container for storing the Terraform state file.
resource "azurerm_storage_container" "tf" {
  name                  = "tfstate-dpe"
  storage_account_id    = azurerm_storage_account.tf.id
  container_access_type = "private"
  
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Locks
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform Storage Account
# └── Management Locks
#     └── Management Lock: `CanNotDelete` on the Terraform Storage Account
#         * Ensures authorized users can read and modify but not delete the storage account or its' resources
resource "azurerm_management_lock" "sa_tf_lock_01" {
  name       = "${azurerm_storage_account.tf.name}-lock-01"
  scope      = azurerm_storage_account.tf.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}

# Terraform Storage Private Endpoints
# └── Management Locks
#     └── Management Lock: `CanNotDelete` on the Private Endpoints
#         * Ensures authorized users can read and modify but not delete the private endpoint or its' resources

resource "azurerm_management_lock" "pep_tf_sa_lock_01" {
  name       = "${azurerm_private_endpoint.tf_storage.name}-lock-01"
  scope      = azurerm_private_endpoint.tf_storage.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}
