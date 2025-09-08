#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------
# Terraform State List 
# -------------------------------------------------------------------------------------------------------
# Run Terraform State List on the TF_CONFIG_DIRECTORY directory.
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

echo -e "${DEF_COLOR}### [tfdir]                        : "${TF_CONFIG_DIRECTORY}
printf '### ';printf '~%.0s' {1..100}; printf '\n'
echo -e "${DEF_COLOR}### [Terraform State List]         : "${4}
printf '### ';printf '~%.0s' {1..100}; printf '\n'

# Executing terraform state list
if [ ${4} == 'all' ]; then    
  ./terraform state list
else  
  ./terraform state list > state_list.out
  cat state_list.out | fgrep ${4}.
fi