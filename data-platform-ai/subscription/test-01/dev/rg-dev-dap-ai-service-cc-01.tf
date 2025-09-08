# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Azure openAI dev instance
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# This file defines the configuration for the openAI instance.
#
# Resources Deployed
# * `module.azure_openAI`           : Module for the openAI instance
#
# Dependencies
# * azurerm_resource_group.dev_openAI                    : Resource group for the dev openAI instance..
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

module "azure_openAI" {
  source              = "Azure/avm-res-cognitiveservices-account/azurerm" # module source
  version             = "0.10.1"                                          # latest version of module at the time of writing
  kind                = "OpenAI"                                          # kind of cognitve service's account
  location            = var.region_CE                                   # Canada east
  name                = "AzureOpenAI-${var.environment}-dap-${var.region}-01"  # name of the service
  resource_group_name = azurerm_resource_group.dev_openAI.name
  local_auth_enabled  = true
  sku_name            = "S0" # standard on demand pay as you go for input and output tokens
  tags                = merge(local.tags_dpe, {"technicalLead": "RAxxx-xxxxxx-xxxxxxxxx-xa"})
  cognitive_deployments = {  # actual model deployments in the instance
    #"text_embedding-ada-02" = {
    #  name = "text-embedding-ada-002"
    #  model = {
    #    format  = "openAI"
    #    name    = "text-embedding-ada-002"
    #    version = "2"
    #  }
    #  scale = {
    #    type = "Standard"
    #  }
    #} # commeting out 4o mini for future so if we want to deploy other models it is easier
    #"gpt-4o-mini" = {
    #  name = "gpt-4o-mini"
    #  model = {
    #    format  = "OpenAI"
    #    name    = "gpt-4o-mini"
    #    version = "2024-07-18"
    #  }
    #  scale = {
    #    type = "Standard"
    #  }
    #}
    "gpt-4o" = {
      name = "gpt-4o"
      model = {
        format  = "OpenAI"
        name    = "gpt-4o"
        version = "2024-11-20"
      }
      scale = {
        type = "Standard"
      }
    }
  }

  network_acls = { # setting default action to Deny for pep
    default_action = "Deny"
  }

  private_endpoints = { # deploying the pep
    pe_endpoint = {
      name                            = "pep-${var.environment}-dap-${var.application}-openai-${var.region}-01"
      private_dns_zone_resource_ids   = toset([data.azurerm_private_dns_zone.openAI.id])
      private_service_connection_name = "pl-${var.environment}-dap-${var.application}-openai-${var.region}-01"
      subnet_resource_id              = azurerm_subnet.snet_ai_dev_pep.id
      location                        = var.region_long
      tags                            = merge(local.tags_dpe, {"technicalLead": "Rxxx-xxxxxx-xxxxxxxxx-xca"})
    }
  }

  # assign Cognitive Services OpenAI Contributor role to dp platform engineer's AD group on the instance to avoid any issues
  role_assignments = {
    dp_platform_ai_ad_group = {
      role_definition_id_or_name = "Cognitive Services OpenAI Contributor"
      principal_id               = data.azuread_group.dp_platform_engineers_ai.object_id
      principal_type             = "Group"
    },
    dp-ai-coe-ops = {
      role_definition_id_or_name = "Cognitive Services OpenAI Contributor"
      principal_id               = data.azuread_group.dp_ai_coe_ops.object_id
      principal_type             = "Group"
    }
  }

  # set a lock on the openAI instance the description cannot be defined but coincedentally it has the same description as our other resources
  lock = {
    kind = var.lock_level
    name = "Openai-${var.environment}-dap-${var.region}-01-lock"
  }

  diagnostic_settings = {
    log_core = {
      name                           = "AzureOpenaiDiagSetting"
      log_groups                     = ["allLogs"]
      workspace_resource_id          = data.azurerm_log_analytics_workspace.core_workspace.id
      storage_account_resource_id    = data.azurerm_storage_account.core_storage_ce.id
      log_analytics_destination_type = "AzureDiagnostics"  # Dedicated is not yet available/supported for Azure openAI
      # not sure why it keeps get updated in the plan despite this being the right setting -> https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics#resource-types
      # I think this is just a newer resource which is why there are issues, best course of action imo would to create a diag setting policy for openAI instance
      # so we don't have to worry about this in terraform (logs are still being sent so there is no issue besides the destination type in tf plan)
    }
  }
}

# lock for the pep as the module does not have this
resource "azurerm_management_lock" "pep_openai_service_01" {
  name       = "pep-${var.environment}-dap-${var.application}-service-${var.region}-01-lock-01"
  scope      = module.azure_openAI.private_endpoints.pe_endpoint.id
  lock_level = var.lock_level
  notes      = var.lock_notes
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Azure AI Search dev instance
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_search_service" "ai_search" {  
  name                = "azuresearch-${var.environment}-dap-${var.region}-01"  
  location            = var.region_CE   
  resource_group_name = azurerm_resource_group.dev_openAI.name  
  sku                 = "standard"  
  partition_count     = 1  
  replica_count       = 1  
  tags = merge(local.tags_dpe, {  
    "technicalLead"          = "Rxxx-xxxxxx-xxxxxxxxx-xa"  
    "technicalLeadSecondary" = "Axxx-xxxxxx-xxxxxxxxx-xa"  
  })  
  public_network_access_enabled = false  
}  
  
# Private endpoint (if needed)  
resource "azurerm_private_endpoint" "ai_search_pep" {  
  name                = "pep-${var.environment}-dap-AzureSearch-${var.region}-01"  
  location            = var.region_long  
  resource_group_name = azurerm_resource_group.dev_openAI.name  
  subnet_id           = azurerm_subnet.snet_ai_dev_pep.id  
  
  private_service_connection {  
    name                           = "pl-${var.environment}-dap-AzureSearch-${var.region}-01"  
    private_connection_resource_id = azurerm_search_service.ai_search.id  
    is_manual_connection           = false  
    subresource_names              = ["searchService"]  
  }  
  
  private_dns_zone_group {  
    name                 = "default"  
    private_dns_zone_ids = [data.azurerm_private_dns_zone.search.id]  
  }  
  
  tags = merge(local.tags_dpe, {  
    "technicalLead"          = "RAxxx-xxxxxx-xxxxxxxxx-x"  
    "technicalLeadSecondary" = "Axxx-xxxxxx-xxxxxxxxx-xa"  
  })  
}  
  
# Diagnostic settings (optional)  
# resource "azurerm_monitor_diagnostic_setting" "ai_search_diag" {  
#   name                       = "azuresearchDiagSetting"  
#   target_resource_id         = azurerm_search_service.ai_search.id  
#   log_analytics_workspace_id = data.azurerm_log_analytics_workspace.core_workspace.id  
#   # storage_account_id         = data.azurerm_storage_account.core_storage_ce.id  
  
#   enabled_log {  
#     category_group = "allLogs" #"SearchQueryLogs"  
#   }  
#   metric {  
#     category = "AllMetrics"  
#     enabled  = true  
#   } 
# }  

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Azure Web App Service instance
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "asp-${var.environment}-dap-${var.region}-01"
  location            = var.region_long
  resource_group_name = azurerm_resource_group.dev_openAI.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                  = "webapp-${var.environment}-dap-${var.region}-01"
  location              = var.region_long
  resource_group_name   = azurerm_resource_group.dev_openAI.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  depends_on            = [azurerm_service_plan.appserviceplan]
  https_only            = true
  site_config { 
    minimum_tls_version = "1.2"
    app_command_line    = "gunicorn --bind=0.0.0.0 --timeout 1200 app:app"
    application_stack {
      python_version = "3.11"
    }
  }
  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }
# APIM & API OPS
#  auth_settings_v2 {
#    active_directory {
#      client_id = azurerm_azuread_application.example.application_id
#      allowed_audiences = [
#        "api://your-application-id",
#        "https://yourwebapp.azurewebsites.net"
#      ]
#    }
#  }
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = azurerm_linux_web_app.webapp.id
  repo_url           = "https://edcteam.visualstudio.com/Data%20Family/_git/dp-dsip-dap-ai-dpe"
  branch             = "WebAPP1"
  use_manual_integration = true
  use_mercurial      = false
}