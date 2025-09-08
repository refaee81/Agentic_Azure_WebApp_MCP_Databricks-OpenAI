#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------
# Azure Login
# -------------------------------------------------------------------------------------------------------
# Login into Azure using the Service Connection defined in the YAML task.
# Set variabales to be used in subsequent YAML tasks.
#
# -------------------------------------------------------------------------------------------------------

set -euo pipefail

# Set the variables
echo -e "### Passed Environment : "${1}
ENV_NAME=${1}

# Show the subscriptions this account has RBAC on
az account show --query "{subscriptionId:id,subscriptionName:name,userType:user.type,isDefault:isDefault}" --output table
#az account show
#Reference: https://github.com/microsoft/azure-pipelines-tasks/blob/master/docs/authoring/commands.md

# Set the common task variables
echo "##vso[task.setvariable variable=AZURE_CLIENT_ID;issecret=true]${servicePrincipalId}"
echo "##vso[task.setvariable variable=AZURE_SUBSCRIPTION_ID;issecret=true]$(az account show --query 'id' -o tsv)"
echo "##vso[task.setvariable variable=AZURE_TENANT_ID;issecret=true]${tenantId}"       

# Set the environment specific task variables
case ${ENV_NAME} in
    "prod"| "mdlg" | "stg"| "dev")
        echo "#1:Environment: ${ENV_NAME}"
        echo "##vso[task.setvariable variable=AZURE_USE_OIDC]true"
        echo "##vso[task.setvariable variable=AZURE_OIDC_TOKEN;issecret=true]${idToken}"

        ;;
    "xyz") # old secret method to authenticate
        echo "#2:Environment: ${ENV_NAME}"
        echo "##vso[task.setvariable variable=AZURE_CLIENT_SECRET;issecret=true]${servicePrincipalKey}"
        ;;
    *)    
        echo "#3:Environment: ${ENV_NAME} is unknown"
        ;;
esac

#Set and Write out the current data/time
#$dateStr = (Get-Date).ToString('MM/dd/yyyy hh:mm:ss tt') 
#Write-Host "##vso[task.setvariable variable=currentDate;]$dateStr"