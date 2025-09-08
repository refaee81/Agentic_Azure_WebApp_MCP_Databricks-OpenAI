#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------
# Terraform State Show
# -------------------------------------------------------------------------------------------------------
# Run Terraform State Show on the TF_CONFIG_DIRECTORY directory.
# -------------------------------------------------------------------------------------------------------
set -euo pipefail

source $(dirname $0)/bash-environment-setup.sh
echo -e "${DEF_COLOR}### Setting variables..."

echo -e "${DEF_COLOR}### Event that caused the BUILD to run : ${BUILD_REASON}"

echo -e "${DEF_COLOR}### Environment : "${3}
ENV_NAME=${3}

echo -e "${DEF_COLOR}### Working Directory : "${1}
WORKING_DIRECTORY=${1}

echo -e "${DEF_COLOR}### Terraform Config Directory : "${2}
TF_CONFIG_DIRECTORY=${2}

# echo -e "${DEF_COLOR}### Terraform Execution Concise Difference is set to: ${3}"
# export TF_X_CONCISE_DIFF=${3}

#validate the executable version on the agent 
echo -e "${DEF_COLOR}### Listing Terraform version in Config Directory ..."
cd ${TF_CONFIG_DIRECTORY}
pwd
./terraform --version

# Building the terraform CMD to execute
export CMD="./terraform state show ${4}.${5}"

echo -e "${DEF_COLOR}### [tfdir]                        : "${TF_CONFIG_DIRECTORY}

# Executing terraform state show
printf '### ';printf '~%.0s' {1..100}; printf '\n'
echo -e "${DEF_COLOR}### [Terraform State Show]         : "${4}.${5}
printf '### ';printf '~%.0s' {1..100}; printf '\n'
$CMD