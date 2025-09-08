
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Resource Group (Network) RBAC
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Assign Resource Group RBAC

resource "azurerm_role_assignment" "network_rg_rbac" {
  for_each = try(local.rbacs_map, {})

  scope                = azurerm_resource_group.network.id
  role_definition_name = each.value.role
  principal_id         = each.value.principal
}



# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# subnet (Pep) 
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


resource "azurerm_subnet" "snet_ai_dev_pep" {
  name                                          = "snet-${var.environment}-dap-${var.application}-pep-${var.region}-01"
  resource_group_name                           = azurerm_resource_group.network.name
  virtual_network_name                          = data.azurerm_virtual_network.dev_ai_vnet.name
  address_prefixes                              = local.snet_environment.subnets_ai.pep.prefixes
  service_endpoints                             = local.snet_environment.subnets_ai.pep.service_endpoints
  private_link_service_network_policies_enabled = local.snet_environment.subnets_ai.pep.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = local.snet_environment.subnets_ai.pep.service_delegations
    content {
      name = delegation.key
      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# NSG (Pep)
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_network_security_group" "pep_nsg" {
  name                = "nsg-${var.environment}-dap-${var.application}-pep-${var.region}-01"
  location            = var.region_long
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags_dpe

  dynamic "security_rule" {
    for_each = local.snet_environment.subnets_ai.pep.nsg.rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges    = lookup(security_rule.value, "destination_port_ranges", null)
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }
  }
  lifecycle {
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Route Table (Profisee) 
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_route_table" "route_table" {
  name                          = "rt-${var.environment}-${var.application}-${var.region}-02"
  location                      = var.region_long
  resource_group_name           = azurerm_resource_group.network.name
  tags                          = local.tags_dpe
  bgp_route_propagation_enabled = false
  dynamic "route" {
    for_each = local.route_tables_ai[local.snet_environment.subnets_ai.pep.route_table]
    content {
      name                   = route.value.name
      address_prefix         = route.value.prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address

      # Conditional assignment of next_hop_in_ip_address for the first 20 routes  
      #next_hop_in_ip_address = contains(["re01", "re02", "re03", "re04", "re05", "re06", "re07", "re08", "re09", "re10", "re11", "re12", "re13", "re14", "re15", "re16", "re17", "re18", "re19", "re20"], route.value.name) ? route.value.next_hop_in_ip_address : null  
    }
  }
}





# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Association (Core & Pep)
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#The resource associations are often used to link various Azure resources together, ensuring they interact and function as intended within your infrastructure.
# 1. azurerm_subnet_network_security_group_association
#This resource associates a Network Security Group (NSG) with a specific subnet. 
#An NSG contains a list of security rules that allow or deny network traffic to resources within that subnet.

# 2. azurerm_subnet_route_table_association
#This resource associates a Route Table with a specific subnet. 
#A Route Table contains a set of routes that dictate how network traffic should be directed within the virtual network. 

#Network Security Group Association for pep Subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association_pep" {
  subnet_id                 = azurerm_subnet.snet_ai_dev_pep.id
  network_security_group_id = azurerm_network_security_group.pep_nsg.id
}
#Route Table Association for pep Subnet
resource "azurerm_subnet_route_table_association" "subnet_route_table_association_pep" {
  subnet_id      = azurerm_subnet.snet_ai_dev_pep.id
  route_table_id = azurerm_route_table.route_table.id
}






/*
#Asjad Networking 
# -----------------------------------------------------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------------------------------------------------
# Contains the resources required to manage the networking components for MLM and GenAI intiative.
#
# Contains the following resources:
#   - Subnets 
#   - Route Table, Route Table Subnet associations, Routes (Common)
#   - Network Security Group, NSG Subnet associations, Security rules (Common)

# Subnets ─> `snet-<sub_env>-dap-ai-<context>-cc-01`
# ├─ Description: Subnet used to deploy Private Endpoint(s) for Azure services such as Private Endpoints, etc.
# ├─ Deployed in VNet: `vnet-<env>-dap-ai-cc-01`
# └─ Address space: `10.101.196.0/22`
#     ├─ pep                              : `1xxx-xxxxxx-xxxxxxxxx-x

# subnet for pep's
resource "azurerm_subnet" "snet_ai_dev_pep" {
  name                              = "snet-${var.environment}-dap-${var.application}-pep-${var.region}-01"
  resource_group_name               = azurerm_resource_group.network.name
  virtual_network_name              = data.azurerm_virtual_network.dev_ai_vnet.name
  address_prefixes                  = [cidrsubnet(data.azurerm_virtual_network.dev_ai_vnet.address_space[0], 4, 0)] # /26 subnet
  private_endpoint_network_policies = "Enabled"

  service_endpoints = [
    "Microsoft.AzureActiveDirectory",
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.CognitiveServices"
  ]
}

# Route Tables ─> Route Table `rt-<env>-dap-ai-cc-01`
# └─ Description: Route Table used to control routing for the PEP Subnet
resource "azurerm_route_table" "rt_pep_dev" {
  name                          = "rt-${var.environment}-dap-${var.application}-${var.region}-01"
  location                      = azurerm_resource_group.network.location
  resource_group_name           = azurerm_resource_group.network.name
  bgp_route_propagation_enabled = false
  tags                          = merge(tomap({ "deviceType" = "microsoft.network/routetables" }), local.tags_dpe)
}

# Route Tables ─> Subnet Route Table `rt-<env>-dap-ai-cc-01` ⇄ Routes
resource "azurerm_route" "rt_pep_dev" {
  for_each = { for idx, i in local.udr_ai_core_01 : "${i.name}-${idx}" => i }

  name                   = each.value.name
  route_table_name       = azurerm_route_table.rt_pep_dev.name
  resource_group_name    = azurerm_resource_group.network.name
  address_prefix         = each.value.prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

# Route Tables ─> Private Endpoint Subnet Route Table `rt-<env>-dap-ai-adb-cc-01` ⇄ Associate with Private Endpoint Subnet `snet-<env>-dap-ai-pep-cc-01`
resource "azurerm_subnet_route_table_association" "pep" {
  subnet_id      = azurerm_subnet.snet_ai_dev_pep.id 
  route_table_id = azurerm_route_table.rt_pep_dev.id
}

# Network Security Groups ─> Private Endpoint Subnet NSG `nsg-<env>-dap-ai-pep-cc-01`
# ├─ Description: Network Security Group used to control inbound and outbound traffic to the Private Endpoint Subnet
resource "azurerm_network_security_group" "nsg_pep" {
  name                = "nsg-${var.environment}-dap-${var.application}-pep-${var.region}-01"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = merge(tomap({ "deviceType" = "microsoft.network/networksecuritygroups" }), local.tags_dpe)
}

# └─ ⇄ Associate NSG `nsg-<env>-dap-ai-pep-cc-01` with Private Endpoint Subnet `snet-<env>-dap-ai-pep-cc-01`
resource "azurerm_subnet_network_security_group_association" "pep" {
  subnet_id                 = azurerm_subnet.snet_ai_dev_pep.id
  network_security_group_id = azurerm_network_security_group.nsg_pep.id
}
*/