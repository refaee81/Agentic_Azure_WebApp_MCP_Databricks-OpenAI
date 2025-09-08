#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------
# Terraform Plan [DRIFT]
# -------------------------------------------------------------------------------------------------------
# Run Terraform Plan on the TF_CONFIG_DIRECTORY directory.
# If the terraform backend state file and the Azure resources are not in sync this task will fail. 
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
if [ ${BUILD_REASON} == 'Schedule' ]; then 
  export TF_CLI_ARGS="-lock=false"
  echo -e "${DEF_COLOR}### This is a Schedule initiated BUILD, exporting TF_CLI_ARGS with: "${TF_CLI_ARGS}
fi

echo -e "${DEF_COLOR}### Calling terraform PLAN from [tfdir] with [tfcliargs], outputting the [tfplan] with -detailed-exitcode for infra drift check."
export TFPLAN_NAME=ai_${ENV_NAME}_${BUILD_BUILDNUMBER}.tfplan

# Building the terraform CMD to execute
export CMD="./terraform plan -detailed-exitcode -input=false -compact-warnings -out ${TFPLAN_NAME}"

echo -e "${DEF_COLOR}### [tfcliargs]   : "${TF_CLI_ARGS}
echo -e "${DEF_COLOR}### [tfplan]      : "${TFPLAN_NAME}
echo -e "${DEF_COLOR}### [tfdir]       : "${TF_CONFIG_DIRECTORY}
echo -e "${DEF_COLOR}### [cmd]         : "${CMD}

# Disable exit on non 0 and run terraform plan and catch return code
set +e
$CMD
RC=$?

# Now enable exit on non 0
set -e

echo -e "${DEF_COLOR}### Return code fom terraform plan is : ${RC}"

if [ ${RC} -eq 0 ]; then
  { echo -e "${DEF_COLOR}### Terraform has no changes. Infrastructure is up-to-date." && exit 0; }
elif [ ${RC} -eq 1 ]; then
  { echo -e "${DEF_COLOR}### Terraform plan has failed." && exit 1; }
elif [ ${RC} -eq 2 ]; then
  { echo -e "${DEF_COLOR}### Terraform has changes. Infrastructure is not up-to-date." && exit 2; }
fi

