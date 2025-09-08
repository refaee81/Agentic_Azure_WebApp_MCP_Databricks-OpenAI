# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# RBAC for resource's and resource groups
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Reader on AI resources resource group for dp_ai_coe_ops AD group
resource "azurerm_role_assignment" "oai_dev_aicoe_reader_01" {
  scope                = azurerm_resource_group.dev_openAI.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.dp_ai_coe_ops.object_id
}


# Contributor on AI search service for dp_ai_coe_ops AD group
resource "azurerm_role_assignment" "oai_dev_aicoe_contributor_01" {
  scope                = azurerm_search_service.ai_search.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.dp_ai_coe_ops.object_id
}

# Reader role on subscription
resource "azurerm_role_assignment" "aicoe_sub_reader_01" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.dp_ai_coe_ops.object_id
}