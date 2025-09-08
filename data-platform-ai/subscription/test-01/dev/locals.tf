locals {
  tags_dpe = {
    application             = var.application_long
    environment             = var.environment_long
    technicalLead           = "Rxxx-xxxxxx-xxxxxxxxx-xa"    
    budgetAuthority         = "gxxx-xxxxxx-xxxxxxxxx-x"    
    SSC_CBRID               = "1xxx-xxxxxx-xxxxxxxxx-x"
    technicalLeadSecondary  = "Axxx-xxxxxx-xxxxxxxxx-xca"
    showBack                = "Dixxx-xxxxxx-xxxxxxxxx-xta"
    productOwner            = "asxxx-xxxxxx-xxxxxxxxx-xc.ca"    
  }
}

locals {
  resource_groups = {
    network = {
      rbacs = [
        {
          role      = "Reader"
          type      = "Group"
          principal = "967xxx-xxxxxx-xxxxxxxxx-x5b3" 
        }                                                    #,  
        #{  
        #  role      = "Reader"  
        #  type      = "User"  
        #  principal = "8exxx-xxxxxx-xxxxxxxxx-xe"  
        #}  
      ]
    }
  }

  rbacs_map = zipmap(
    range(length(local.resource_groups.network.rbacs)),
    local.resource_groups.network.rbacs
  )
}

#subnets_erwin
#route_tables_erwin

locals {
  environments = {
    dev = {
      subnets_ai = {
        pep = {
          prefixes                                      = ["1xxx-xxxxxx-xxxxxxxxx-x/26"]
          service_endpoints                             = ["Microsoft.Storage", "Microsoft.AzureActiveDirectory", "Microsoft.Storage", "Microsoft.KeyVault","Microsoft.CognitiveServices"]
          private_endpoint_network_policies             = "Enabled"
          private_link_service_network_policies_enabled = true
          service_delegations                           = {}
          route_table                                   = "rt_main"
          nsg = {
            rules = [
              {
                name                       = "AllowCoreSubnetInbound"
                priority                   = 151
                direction                  = "Inbound"
                access                     = "Allow"
                protocol                   = "Tcp"
                source_port_range          = "*"
                destination_port_ranges    = ["443"]
                source_address_prefix      = "xxx-xxxxxx-xxxxxxxxx-x/26"
                destination_address_prefix = "*"
                description                = "Allow inbound traffic from Core Subnet"
              },
              {
                name                       = "AllowClouds2XAgentsSubnetInbound"
                priority                   = 4090
                direction                  = "Inbound"
                access                     = "Allow"
                protocol                   = "Tcp"
                source_port_range          = "*"
                destination_port_range     = "443"
                source_address_prefix      = "1xxx-xxxxxx-xxxxxxxxx-x/27"
                destination_address_prefix = "*"
                description                = "Allow inbound traffic from DevOps Agents of Clouds2X pool"
              },
              {
                name                       = "DenyVNetAddressSpaceInbound"
                description                = "Deny inbound vnet traffic particular to this address space"
                direction                  = "Inbound"
                source_address_prefix      = "1xxx-xxxxxx-xxxxxxxxx-x/25"
                source_port_range          = "*"
                destination_address_prefix = "11xxx-xxxxxx-xxxxxxxxx-x0/25"
                destination_port_range     = "*"
                protocol                   = "*"
                access                     = "Deny"
                priority                   = 4096
              }
            ]
          }
        }
      }
    }
  }

  snet_environment = local.environments[var.environment]

  route_tables_ai = {
    rt_main = {
      re1 = {
        name                   = "default_route"
        prefix                 = "0xxx-xxxxxx-xxxxxxxxx-x0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "1xxx-xxxxxx-xxxxxxxxx-x6"
      },
      re2 = {
        name                   = "to_on_prem1"
        prefix                 = "1xxx-xxxxxx-xxxxxxxxx-x8"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10xxx-xxxxxx-xxxxxxxxx-x132"
      },
      re3 = {
        name                   = "to_azure_cc"
        prefix                 = "1xxx-xxxxxx-xxxxxxxxx-x6"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "xxx-xxxxxx-xxxxxxxxx-x"
      },
      re4 = {
        name                   = "to_snet-core-c8000vinternet-cc-01"
        prefix                 = "xxx-xxxxxx-xxxxxxxxx-x28"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "1xxx-xxxxxx-xxxxxxxxx-x2"
      },
      re5 = {
        name                   = "to_snet-core-c8000vazinternal-cc-01"
        prefix                 = "1xxx-xxxxxx-xxxxxxxxx-x28"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "xxx-xxxxxx-xxxxxxxxx-x2"
      },
      re6 = {
        name                   = "to_snet-core-dns-cc-01"
        prefix                 = "xxx-xxxxxx-xxxxxxxxx-x6/27"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "1xxx-xxxxxx-xxxxxxxxx-x32"
      },
      re7 = {
        name                   = "to_snet-core-iam-cc-01"
        prefix                 = "xxx-xxxxxx-xxxxxxxxx-x6"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "xxx-xxxxxx-xxxxxxxxx-x2"
      },
      re8 = {
        name                   = "to_snet-core-ss-cc-01"
        prefix                 = "xxx-xxxxxx-xxxxxxxxx-x/26"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "xxx-xxxxxx-xxxxxxxxx-x32"
      },
      re9 = {
        name                   = "to_snet-core-appgw-cc-01"
        prefix                 = "xxx-xxxxxx-xxxxxxxxx-x/24"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "xxx-xxxxxx-xxxxxxxxx-x2"
      },
      re10 = {
        name                   = "to_snet-core-c8000ver-cc-01"
        prefix                 = "1xxx-xxxxxx-xxxxxxxxx-x/28"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "1xxx-xxxxxx-xxxxxxxxx-x2"
      },
      re11 = {
        name                   = "to_snet-core-c8000vvpn-cc-01"
        prefix                 = "1xxx-xxxxxx-xxxxxxxxx-x6/28"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "xxx-xxxxxx-xxxxxxxxx-x.132"
      },
      re12 = {
        name                   = "to_snet-core-pe-cc-01"
        prefix                 = "xxx-xxxxxx-xxxxxxxxx-x/23"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "xxx-xxxxxx-xxxxxxxxx-x32"
      },
      re13 = {
        name                   = "to_snet-core-vmtest-cc-01"
        prefix                 = "1xxx-xxxxxx-xxxxxxxxx-x/24"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "1xxx-xxxxxx-xxxxxxxxx-x"
      },
      re14 = {
        name                   = "to_azure_ce"
        prefix                 = "xxx-xxxxxx-xxxxxxxxx-x/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "1xxx-xxxxxx-xxxxxxxxx-x132"
      },
      re15 = {
        name                   = "to_on_prem3"
        prefix                 = "xxx-xxxxxx-xxxxxxxxx-x/12"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "1xxx-xxxxxx-xxxxxxxxx-x132"
      },
      re16 = {
        name                   = "to_on_prem2"
        prefix                 = "1xxx-xxxxxx-xxxxxxxxx-x/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "1xxx-xxxxxx-xxxxxxxxx-x132"
      },
      re17 = {
        name                   = "AzureKMS2"
        prefix                 = "xxx-xxxxxx-xxxxxxxxx-x4/32"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      },
      re18 = {
        name                   = "AzureKMS1"
        prefix                 = "2xxx-xxxxxx-xxxxxxxxx-x6/32"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      },
      re19 = {
        name                   = "AzureKMS3"
        prefix                 = "4xxx-xxxxxx-xxxxxxxxx-x3/32"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      },
      re20 = {
        name                   = "to_microsoft_cdn"
        prefix                 = "AzureFrontDoor.Backend"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      },
      re21 = {
        name                   = "to_avd_control_plane"
        prefix                 = "WindowsVirtualDesktop"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      },
      re22 = {
        name                   = "to_snet-core-azdosha-cc-01"
        prefix                 = "1xxx-xxxxxx-xxxxxxxxx-x/27"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "1xxx-xxxxxx-xxxxxxxxx-x2"
      }
    }
  }
}










/*
#Asjad Locals
locals {
  udr_ai_core_01 = [
    {
      name                   = "on_prem1"
      prefix                 = "10.0.0.0/8"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.101.0.132"
    },
    {
      name                   = "on_prem2"
      prefix                 = "192.168.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.101.0.132"
    },
    {
      name                   = "on_prem3"
      prefix                 = "172.16.0.0/12"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.101.0.132"
    }, 
    {
      name                   = "default_route"
      prefix                 = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.101.1.196"
    },
    {
      name                   = "to_azure_cc"
      prefix                 = "10.101.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.101.0.132"
    },
    {
      name                   = "to_azure_ce"
      prefix                 = "10.102.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.101.0.132"
    }
  ]
}
*/