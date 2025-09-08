# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Storage Account for dev openAI
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#
# Resources Deployed
# * `azurerm_storage_account.sa_dev_ai_01`        : Storage account for dev openAI.
# * `azurerm_role_assignment.sa_dev_ai_rbac[*]`   : Role assignments for granting access to the storage account.
# * `azurerm_private_endpoint.sa_dev_ai_blob`     : Private endpoint for accessing the storage account blob services securely.
# * `azurerm_private_endpoint.sa_dev_ai_dfs`      : Private endpoint for accessing the storage account dfs services securely.
# * `azurerm_management_lock.sa_dev_ai_01_lock[*]`: Management lock for protecting the storage account from accidental deletion.
#* `azurerm_management_lock.pep_sa_dev_ai_lock[*]`: Management lock for protecting the private endpoint from accidental deletion.
#
# Dependencies
# * azurerm_resource_group.tf                     : Resource group for the Terraform storage account.
# * data.azurerm_client_config.current            : Current Azure client configuration.
# * data.azuread_group.dp_platform_engineers_ai   : Azure AD group for platform engineers.
# * data.azurerm_private_dns_zone.sa_blob         : Private DNS zone for the storage account blob service.
# * azurerm_subnet.snet_ai_dev_pep                : Subnet for the private endpoint.
# * local.tags_dpe                                : Tags for the storage account.
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Storage Account
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Random String for Terraform Storage Account Suffix
resource "random_string" "sa_dev_ai_01_suffix" {
  length  = 8
  numeric = true
  special = false
  upper   = false
}

# Terraform Storage Account
#   * Storage account for storing the Terraform state file.
resource "azurerm_storage_account" "sa_dev_ai_01" {
  name                             = "dls${var.environment}dap${var.application}${random_string.sa_dev_ai_01_suffix.result}"
  resource_group_name              = azurerm_resource_group.storage_ai.name
  location                         = azurerm_resource_group.storage_ai.location
  cross_tenant_replication_enabled = false
  account_kind                     = "StorageV2"
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  access_tier                      = "Hot"
  is_hns_enabled                   = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  tags                             = merge(local.tags_dpe, {"technicalLead": "RAbxxx-xxxxxx-xxxxxxxxx-x.ca"})
  public_network_access_enabled    = false
  shared_access_key_enabled        = false

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
# Set Advanced Threat Protection on the storage account
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ADLS
# └── This feature helps with detecting and responding to potential threats on storage account as they occur.
resource "azurerm_advanced_threat_protection" "sa_dev_ai_01_atp" {
  target_resource_id = azurerm_storage_account.sa_dev_ai_01.id
  enabled            = false
  depends_on         = [azurerm_storage_account.sa_dev_ai_01]
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
resource "azurerm_role_assignment" "sa_dev_ai_01" {
  scope                = azurerm_storage_account.sa_dev_ai_01.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "sa_dev_ai_02" {
  scope                = azurerm_storage_account.sa_dev_ai_01.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "sa_dev_ai_03" {
  scope                = azurerm_storage_account.sa_dev_ai_01.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_group.dp_platform_engineers_ai.object_id
}

resource "azurerm_role_assignment" "sa_dev_ai_04" {
  scope                = azurerm_storage_account.sa_dev_ai_01.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.dp_platform_engineers_ai.object_id
}


# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Private Endpoints
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Terraform Storage Account
# └── Private Endpoints
#     └── Private Endpoint `pep-<env>-dap-ai-tf-cc-01` (Blob)
resource "azurerm_private_endpoint" "sa_dev_ai_blob" {

  name                = "pep-${var.environment}-dap-${var.application}-blob-${var.region}-01"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  subnet_id           = azurerm_subnet.snet_ai_dev_pep.id
  tags                = merge(local.tags_dpe, {"technicalLead": "RAxxx-xxxxxx-xxxxxxxxx-x.ca"})

  private_service_connection {
    name                           = "pl-${var.environment}-dap-${var.application}-tf-${var.region}-01"
    private_connection_resource_id = azurerm_storage_account.sa_dev_ai_01.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
    request_message                = null
  }

  private_dns_zone_group {
    name                 = data.azurerm_private_dns_zone.sa_blob.name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.sa_blob.id]
  }
}

# ADLS
# └── Private Endpoints
#     └── Private Endpoint `pep-<env>-dap-ai-dfs-cc-01`
#           * Private Endpoint used to access dfs.
resource "azurerm_private_endpoint" "sa_dev_ai_dfs" {
  name                = "pep-${var.environment}-dap-${var.application}-dfs-${var.region}-01-1"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  subnet_id           = azurerm_subnet.snet_ai_dev_pep.id
  tags                = merge(local.tags_dpe, {"technicalLead": "RAbdxxx-xxxxxx-xxxxxxxxx-xca"})

  private_service_connection {
    name                           = "pl-${var.environment}-dap-${var.application}-dfs-${var.region}-01"
    private_connection_resource_id = azurerm_storage_account.sa_dev_ai_01.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
    request_message                = null
  }

  private_dns_zone_group {
    name                 = data.azurerm_private_dns_zone.sa_dfs.name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.sa_dfs.id]
  }
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Locks
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Storage Account
# └── Management Locks
#     └── Management Lock: `CanNotDelete` on the dev ai Storage Account
#         * Ensures authorized users can read and modify but not delete the storage account or its' resources
resource "azurerm_management_lock" "sa_dev_ai_lock_01" {
  name       = "${azurerm_storage_account.sa_dev_ai_01.name}-lock-01"
  scope      = azurerm_storage_account.sa_dev_ai_01.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}

# Storage Private Endpoints
# └── Management Locks
#     └── Management Lock: `CanNotDelete` on the Private Endpoints
#         * Ensures authorized users can read and modify but not delete the private endpoint or its' resources

resource "azurerm_management_lock" "pep_sa_dev_ai_01_blob" {
  name       = "${azurerm_private_endpoint.sa_dev_ai_blob.name}-lock-01"
  scope      = azurerm_private_endpoint.sa_dev_ai_blob.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}

resource "azurerm_management_lock" "pep_sa_dev_ai_01_dfs" {
  name       = "${azurerm_private_endpoint.sa_dev_ai_dfs.name}-lock-01"
  scope      = azurerm_private_endpoint.sa_dev_ai_dfs.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}
