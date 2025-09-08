#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------
# Terraform Apply
# -------------------------------------------------------------------------------------------------------
# Run Terraform Apply using the PLAN generated TFPLAN_NAME in the previous YAML stage.
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

echo -e "${DEF_COLOR}### Calling terraform APPLY from [tfdir] and passing the [tfplan]"
export TFPLAN_NAME=ai_${ENV_NAME}_${BUILD_BUILDNUMBER}.tfplan

# Building the terraform CMD to execute
export CMD="./terraform apply -lock=true -compact-warnings ${TFPLAN_NAME}"

echo -e "${DEF_COLOR}### [tfplan] : "${TFPLAN_NAME}
echo -e "${DEF_COLOR}### [tfdir]  : "${TF_CONFIG_DIRECTORY}
echo -e "${DEF_COLOR}### [cmd]    : "${CMD}

# Executing the terraform CMD
$CMD