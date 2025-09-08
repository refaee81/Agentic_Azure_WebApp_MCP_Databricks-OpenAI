terraform {
  required_version = "<= 1.11.1"
  required_providers {
    azurerm = {
      # The "hashicorp" namespace is the new home for the HashiCorp-maintained provider plugins.

      # source is not required for the hashicorp/* namespace as a measure of backward compatibility for commonly-used providers, but recommended for explicitness.

      version = "~> 4.17.0"
    }

    random = {
      version = "~> 3.6.3"
    }

    #Configure the Microsoft Azure Active Directory Provider
    azuread = {
      version = "~> 3.1.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none" # expected values ["none" "legacy" "core" "extended" "all"]  # Disable automatic registration of Azure resource provider (https://www.puppeteers.net/blog/terraform-azure-resource-provider-registration-fails/)
  features {
    /*      api_management {
        purge_soft_delete_on_destroy         = true
        recover_soft_deleted_api_managements = true
      } */

    /*       application_insights {
        disable_generated_rule = false
      } */

    /*       cognitive_account {
        purge_soft_delete_on_destroy = true
      } */

    /*       key_vault {
        purge_soft_delete_on_destroy    = true
        recover_soft_deleted_key_vaults = true
      } */

    /*       log_analytics_workspace {
        permanently_delete_on_destroy = true
      } */

    resource_group {
      prevent_deletion_if_contains_resources = true
    }

    /*       template_deployment {
        delete_nested_items_during_deletion = true
      } */

    /*       virtual_machine {
        delete_os_disk_on_deletion     = true
        graceful_shutdown              = false
        skip_shutdown_and_force_delete = false
      } */

    /*       virtual_machine_scale_set {
        force_delete                  = false
        roll_instances_when_required  = true
        scale_to_zero_before_deletion = true
      } */
  }

  storage_use_azuread = true
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none" # expected values ["none" "legacy" "core" "extended" "all"]
  alias                      = "hubcc_subscription"
  subscription_id            = "30xxx-xxxxxx-xxxxxxxxx-x3f"
}