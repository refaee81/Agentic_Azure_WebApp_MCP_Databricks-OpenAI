# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#
# Contains definitions for the following data sources:
#
# Resource Containers
# - Azure Provider Configuration
# - Azure Subscription
# - Resource Group
#
# Security Principals
# - Azure AD / MS Entra Groups
# - Azure AD / MS Entra Users
# - Azure AD / MS Entra Service Principals
#
# Network Resources
# - Private DNS Zones
#
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Client Config of current spn/app registration signed in
data "azurerm_client_config" "current" {
}

# Resource Containers -> Resource Groups ─> `azurerm_resource_group.hub-private_dns_zones`
# ├─ Description : Resource container within the `prod-core-01` subscription containing Private DNS Zones
# └─ Source      : [`rg-cxxxxxx-xxxxxx-xxxxxxxxx-xxxxx-cc-01`](https://portal.azure.com/#@.onmicrosoft.com/resource/subscriptions/xxxxxx-xxxxxx-xxxxxxxxx-xxxxx3f/resourceGroups/rg-core-ss-cc-01)
data "azurerm_resource_group" "hub-private_dns_zones" {
  provider = azurerm.hxxxxc_subscription
  name     = "rg-xxxxxx-xxxxxx-xxxxxxxxx-xxxxx-cc-01"
}

# Groups ─> `dp-platform-engineers-ai`
# ├─ Description : Azure AD Group containing the Data Platform Engineering team members specific to the Data Storage and Integration Platform
# └─ Source      : [`dp-plxxx-xxxxxx-xxxxxxxxx-xers-ai`](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/2d69dxxxxxx-xxxxxx-xxxxxxxxx-xxxxxe5e4)
data "azuread_group" "dp_pxxx-xxxxxx-xxxxxxxxx-xers_ai" {
  object_id = "2dxxxxxxx-xxxxxx-xxxxxxxxx-xxxxx5e4"
}

# Groups ─> `dp-ai-coe-ops`
# ├─ Description : Azure AD Group containing the AI COE members
# └─ Source      : [`dp-xxx-xxxxxx-xxxxxxxxx-x-ops`](https://portal.azure.com/#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/8b622512-8ade-4xxx-xxxxxx-xxxxxxxxx-xfe/menuId/)
data "azuread_group" "dp_xxx-xxxxxx-xxxxxxxxx-x_ops" {
  object_id = "8b6xxx-xxxxxx-xxxxxxxxx-xdfe"
}

# Private DNS Zones ─> `azurerm_private_dns_zone.sa_blob`
# ├─ Description : Private DNS Zone for Storage account blob (Microsoft.Storage/storageAccounts)
# └─ Source      : [`privatelink.blob.core.windows.net`](https://portal.azure.com/#@a.onmicrosoft.com/resource/subscriptions/303xxx-xxxxxx-xxxxxxxxx-xd3f/resourceGroups/rg-core-ss-cc-01/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net/resourceOverviewId)
data "azurerm_private_dns_zone" "sa_blob" {
  provider            = azurerm.hubcc_subscription
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.hub-private_dns_zones.name
}

# Private DNS Zones ─> `azurerm_private_dns_zone.sa_dfs`
# ├─ Description : Private DNS Zone for Storage account dfs (Microsoft.Storage/storageAccounts)
# └─ Source      : [`privatelink.dfs.core.windows.net`](https://portal.azure.com/#@Eada.onmicrosoft.com/resource/subscriptions/303xxx-xxxxxx-xxxxxxxxx-x4cd3f/resourceGroups/rg-core-ss-cc-01/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net/resourceOverviewId)
data "azurerm_private_dns_zone" "sa_dfs" {
  provider            = azurerm.hubcc_subscription
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = data.azurerm_resource_group.hub-private_dns_zones.name
}

# Private DNS Zones ─> `azurerm_private_dns_zone.kv`
# ├─ Description : Private DNS Zone for Azure Key Vault (Microsoft.KeyVault/vaults)
# └─ Source      : [`privatelink.vaultcore.azure.net`](https://portal.azure.com/#@da.onmicrosoft.com/resource/subscriptions/303dxxx-xxxxxx-xxxxxxxxx-xcd3f/resourceGroups/rg-core-ss-cc-01/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net/resourceOverviewId)
data "azurerm_private_dns_zone" "kv" {
  provider            = azurerm.hubcc_subscription
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = data.azurerm_resource_group.hub-private_dns_zones.name
}

# Private DNS Zone for the openAI instance
data "azurerm_private_dns_zone" "openAI" {
  provider            = azurerm.hubcc_subscription
  name                = "privatelink.openai.azure.com"
  resource_group_name = data.azurerm_resource_group.hub-private_dns_zones.name
}

# Private DNS Zone for the aisearch instance
data "azurerm_private_dns_zone" "search" {
  provider            = azurerm.hubcc_subscription
  name                = "privatelink.search.windows.net"
  resource_group_name = data.azurerm_resource_group.hub-private_dns_zones.name
}

data "azurerm_log_analytics_workspace" "core_workspace" {
  provider            = azurerm.hubcc_subscription
  name                = "log-xxx-xxxxxx-xxxxxxxxx-xs-cc-01"
  resource_group_name = "rg-xxx-xxxxxx-xxxxxxxxx-x-cc-01"
}

data "azurerm_storage_account" "core_storage_cc" {
  provider            = azurerm.hubcc_subscription
  name                = "sacorestresourcelogscc01"
  resource_group_name = "rg-cxxx-xxxxxx-xxxxxxxxx-x-cc-01"
}

data "azurerm_storage_account" "core_storage_ce" {
  provider            = azurerm.hubcc_subscription
  name                = "sacorestresourcelogsce01"
  resource_group_name = "rg-xxx-xxxxxx-xxxxxxxxx-x-ce-01"
}

# the dev vnet for ai resource's
data "azurerm_virtual_network" "dev_ai_vnet" {
  name = "vnetxxx-xxxxxx-xxxxxxxxx-xai-cc-01"
  resource_group_name = "rg-dexxx-xxxxxx-xxxxxxxxx-xnw-cc-01"
}