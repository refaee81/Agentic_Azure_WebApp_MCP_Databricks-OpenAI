#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------
# Terraform Imports
# -------------------------------------------------------------------------------------------------------
# Run Terraform Import on the TF_CONFIG_DIRECTORY directory.
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

# Listt out the directory to view the files
echo -e "${DEF_COLOR}### Listing current Directory ..."
pwd
ls -latr  


# Set a variable to the file name which contains the terraform import cmds
# for files in $(ls -1tr *import*.tf); do
#     export TFIMPORTFILE=$(echo $files | awk '{print $1}')
#     echo -e "${DEF_COLOR}### Import file found as: "${TFIMPORTFILE}
#     echo -e "${DEF_COLOR}### Import file contents: "
#     cat ${TFIMPORTFILE}
# done

# Building the terraform CMD to execute
export CMD="source tfimport.sh"

echo -e "${DEF_COLOR}### Calling terraform IMPORT from [tfdir]"
echo -e "${DEF_COLOR}### [tfdir] : "${TF_CONFIG_DIRECTORY}
echo -e "${DEF_COLOR}### [cmd]   : "${CMD}

# Executing the terraform imports found in the imports file
echo -e "${DEF_COLOR}### Executing the terraform imports ..."
$CMD
