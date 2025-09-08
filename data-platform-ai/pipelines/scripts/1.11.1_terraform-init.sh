#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------
# Terraform Init
# -------------------------------------------------------------------------------------------------------
# Run Terraform Init on the TF_CONFIG_DIRECTORY directory.
# To setup the environment and backend, providers are downloaded in this task.
#
# -------------------------------------------------------------------------------------------------------
set -euo pipefail

source $(dirname $0)/bash-environment-setup.sh
echo -e "${DEF_COLOR}### Setting variables..."

echo -e "${DEF_COLOR}### Environment : "${3}
ENV_NAME=${3}

echo -e "${DEF_COLOR}### Working Directory : "${1}
WORKING_DIRECTORY=${1}

echo -e "${DEF_COLOR}### Terraform Config Directory : "${2}
TF_CONFIG_DIRECTORY=${2}

#validate the executable version on the agent 
echo -e "${DEF_COLOR}### Listing Terraform version in Config Directory ..."
cd ${TF_CONFIG_DIRECTORY}
pwd
./terraform --version

# Building the terraform CMD to execute
export CMD="./terraform init -input=false"

echo -e "${DEF_COLOR}### Calling terraform INIT from [tfdir]"
echo -e "${DEF_COLOR}### [tfdir] : "${TF_CONFIG_DIRECTORY}
echo -e "${DEF_COLOR}### [cmd]   : "${CMD}

# Executing the terraform CMD
$CMD