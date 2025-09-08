#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------
# Terraform Plan  
# -------------------------------------------------------------------------------------------------------
# Run Terraform Plan on the TF_CONFIG_DIRECTORY directory.
# An output PLAN file TFPLAN_NAME is generated for input into the APPLY stage of the YAML.
#
# -------------------------------------------------------------------------------------------------------
set -euo pipefail

source $(dirname $0)/bash-environment-setup.sh
echo -e "${DEF_COLOR}### Setting variables..."

echo -e "${DEF_COLOR}### Event that caused the BUILD to run : ${BUILD_REASON}"

echo -e "${DEF_COLOR}### Environment : "${4}
ENV_NAME=${4}

echo -e "${DEF_COLOR}### Working Directory : "${1}
WORKING_DIRECTORY=${1}

echo -e "${DEF_COLOR}### Terraform Config Directory : "${2}
TF_CONFIG_DIRECTORY=${2}

echo -e "${DEF_COLOR}### Terraform Execution Concise Difference is set to: ${3}"
export TF_X_CONCISE_DIFF=${3}

#validate the executable version on the agent 
echo -e "${DEF_COLOR}### Listing Terraform version in Config Directory ..."
cd ${TF_CONFIG_DIRECTORY}
pwd
./terraform --version

export TF_CLI_ARGS=""
if [ ${BUILD_REASON} == 'PullRequest' ]; then 
  export TF_CLI_ARGS="-lock=false"
  echo -e "${DEF_COLOR}### This is a PullRequest initiated BUILD, exporting TF_CLI_ARGS with: "${TF_CLI_ARGS}
fi

echo -e "${DEF_COLOR}### Calling terraform PLAN from the [tfdir] with [tfcliargs], outputting the [tfplan]"
export TFPLAN_NAME=ai_${ENV_NAME}_${BUILD_BUILDNUMBER}.tfplan

# Building the terraform CMD to execute
export CMD="./terraform plan -input=false -compact-warnings -out ${TFPLAN_NAME}"

echo -e "${DEF_COLOR}### [tfcliargs]   : "${TF_CLI_ARGS}
echo -e "${DEF_COLOR}### [tfplan]      : "${TFPLAN_NAME}
echo -e "${DEF_COLOR}### [tfdir]       : "${TF_CONFIG_DIRECTORY}
echo -e "${DEF_COLOR}### [cmd]         : "${CMD}

# Executing the terraform CMD
$CMD