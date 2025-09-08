variable "tenant_id" {
  description = "The Azure Tenant ID where the resources are deployed."
  type        = string
  default     = "dxxx-xxxxxx-xxxxxxxxx-x0" # 
}

variable "application_long" {
  description = <<DESCRIPTION
    The name of the application/platform which the resource is supporting.
    Example(s): [ Analytics | Data | Denodo | EDP | MasterData | Power BI | SAS Viya | AI]
  DESCRIPTION
  type        = string
  default     = "AI"
}

variable "application" {
  description = <<DESCRIPTION
    The short name of the application/platform which the resource is supporting.
    Example(s): [ analytics | data | denodo | edp | masterdata | powerbi | sasviya | ai]
  DESCRIPTION
  type        = string
  default     = "ai"
}

variable "environment_long" {
  description = <<DESCRIPTION
    The application / platform environment where the resources are deployed. 
    Example(s): [ DEV | QAC | PPR | MDLG | STG | PROD ]
  DESCRIPTION
  type        = string
  default     = "DEV"
}

variable "environment" {
  description = <<DESCRIPTION
    The short name of the environment, derived by casting `var.environment_long` to lowercase.
    Example(s): [ dev | qac | ppr | mdlg | stg | prod ]
  DESCRIPTION
  type        = string
  default     = "dev"
}

variable "region_long" {
  description = <<DESCRIPTION
    The Azure Region where the resource is deployed.
    Example(s): [ canadacentral | canadaeast ]
  DESCRIPTION
  type        = string
  default     = "canadacentral"
}

variable "region_CE" {
  description = <<DESCRIPTION
    The Azure Region where the resource is deployed.
    Example(s): [ canadacentral | canadaeast ]
  DESCRIPTION
  type        = string
  default     = "canadaeast"
}

variable "region" {
  description = <<DESCRIPTION
    The short name of the Azure Region where the resource is deployed.
    Example(s): [ cc | ce ]
  DESCRIPTION
  type        = string
  default     = "cc"
}

variable "lock_name" {
  description = <<DESCRIPTION
     Specifies the name of the management lock. Changing this forces a new resource to be created.
  DESCRIPTION  
  type        = string
  default     = "DoNotDelete"
}

variable "lock_level" {
  description = <<DESCRIPTION
     Specifies the level to be used for this lock.
     Example(s): [ CanNotDelete | ReadOnly ]
     Note: CanNotDelete means authorized users are able to read and modify the resources, but not delete.   
           ReadOnly means authorized users can only read from a resource, but they can't modify or delete it.
  DESCRIPTION  
  type        = string
  default     = "CanNotDelete"
}

variable "lock_notes" {
  description = <<DESCRIPTION
     Specifies some notes about the lock.
  DESCRIPTION  
  type        = string
  default     = "Cannot delete the resource or its child resources."
}

variable "subscription_id" {
  description = "The subscription id"
  type        = string
  default     = "bxxx-xxxxxx-xxxxxxxxx-x2"
}