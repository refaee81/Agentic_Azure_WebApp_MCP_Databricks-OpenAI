# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# This file defines the configuration for the primary / default Key Vault resource within the environment used for storing secrets and certificates.
#
# Resources Deployed
# * `azurerm_key_vault.kv_dev_ai_01`                        : Key Vault resource for storing secrets and certificates.
# * `azurerm_role_assignment.kv_dev_ai_01_rbac_xx[*]`       : Role assignments for granting access to the Key Vault.
# * `azurerm_private_endpoint.kv_dev_ai_01`                 : Private endpoint for accessing the Key Vault securely.
# * `azurerm_management_lock.kv_dev_ai_01_lock[*]`          : Management locks for protecting the Key Vault from accidental deletion.
# * `azurerm_management_lock.pep_kv_dev_ai_01_lock[*]`      : Management lock for protecting the private endpoint from accidental deletion.
#
# Dependencies
# * azurerm_resource_group.sec                    : Resource group for the Key Vault.
# * data.azurerm_client_config.current            : Current Azure client configuration.
# * data.azuread_group.dp_platform_engineers_ai   : Azure AD group for platform engineers.
# * local.tags_dpe                                : Tags for the Key Vault.
# * data.azurerm_private_dns_zone.kv              : Private DNS zone for the Key Vault.
# * data.azurerm_resource_group.nw                : Resource group for the networking resources.
# * azurerm_subnet.snet_ai_mdlg_pep               : Subnet for the private endpoint.
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Key Vault
#   * Primary Key Vault resource within the environment used for storing secrets and certificates.
resource "azurerm_key_vault" "kv_dev_ai_01" {
  name                      = "kv-${var.environment}-dap-${var.application}-${var.region}-01"
  location                  = azurerm_resource_group.sec_ai.location
  resource_group_name       = azurerm_resource_group.sec_ai.name
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = null
    virtual_network_subnet_ids = []
  }
  purge_protection_enabled      = true
  public_network_access_enabled = false
  soft_delete_retention_days    = 90
  tags = merge(local.tags_dpe, {"technicalLead": "Rxxx-xxxxxx-xxxxxxxxx-xca"})
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Role Assignments
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Key Vault
# └── Role Assignments
#     ├── Grant `Key Vault Administrator` role to `dp-platform-engineers-ai` group on the Key Vault
#     |     * Enables platform engineers to manage the Key Vault and its contents
#     ├── Grant `Key Vault Crypto Officer` role to the terraform service principal on the Key Vault
#     |     * Grants full management capabilities over keys including the ability to create, delete, and list keys, etc.
#     └── Grant `Key Vault Secrets Officer` role to the terraform service principal on the Key Vault
#           * Grants full management capabilities over secrets including the ability to create, delete, and list secrets, etc.
resource "azurerm_role_assignment" "kv_dev_ai_01_rbac_01" {
  scope                = azurerm_key_vault.kv_dev_ai_01.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_group.dp_platform_engineers_ai.object_id
}
resource "azurerm_role_assignment" "kv_dev_ai_01_rbac_02" {
  scope                = azurerm_key_vault.kv_dev_ai_01.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_role_assignment" "kv_dev_ai_01_rbac_03" {
  scope                = azurerm_key_vault.kv_dev_ai_01.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Private Endpoints
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Key Vault
# └── Private Endpoints
#     └── Private Endpoint `pep-<env>-dap-ai-kv-cc-01`
#           * Private Endpoint used to access the Key Vault securely
resource "azurerm_private_endpoint" "kv_dev_ai_01" {
  name                = "pep-${var.environment}-dap-${var.application}-kv-${var.region}-01"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  subnet_id           = azurerm_subnet.snet_ai_dev_pep.id
  private_service_connection {
    name                           = "pl-${var.environment}-dap-${var.application}-kv-${var.region}-01"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.kv_dev_ai_01.id
    subresource_names              = ["vault"]
  }
  private_dns_zone_group {
    name                 = data.azurerm_private_dns_zone.kv.name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.kv.id]
  }

  tags = merge(local.tags_dpe, {"technicalLead": "RAxxx-xxxxxx-xxxxxxxxx-x.ca"})
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Resource Locks
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Azure Key Vault
# └── Management Locks
#     └── Management Lock: `CanNotDelete` on the Key Vault
#         * Ensures authorized users can read and modify but not delete the key vault or its' resources
resource "azurerm_management_lock" "kv_dev_ai_01_lock_01" {
  name       = "${azurerm_key_vault.kv_dev_ai_01.name}-lock-01"
  scope      = azurerm_key_vault.kv_dev_ai_01.id
  lock_level = var.lock_level
  notes      = var.lock_notes

  depends_on = [azurerm_key_vault.kv_dev_ai_01]
}

# Key Vault Private Endpoints
# └── Management Locks
#     └── Management Lock: `CanNotDelete` on the Private Endpoints
#         * Ensures authorized users can read and modify but not delete the private endpoint or its' resources

resource "azurerm_management_lock" "pep_kv_dev_ai_01_lock_01" {
  name       = "${azurerm_private_endpoint.kv_dev_ai_01.name}-lock-01"
  scope      = azurerm_private_endpoint.kv_dev_ai_01.id
  lock_level = var.lock_level
  notes      = var.lock_notes

  depends_on = [azurerm_private_endpoint.kv_dev_ai_01]
}
