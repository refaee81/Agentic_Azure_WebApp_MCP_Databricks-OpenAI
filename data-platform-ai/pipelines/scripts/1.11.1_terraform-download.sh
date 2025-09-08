#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------
# Terraform Download
# -------------------------------------------------------------------------------------------------------
# Download Terraform executable zip file, extract to ENV path and validate the version.
#
# -------------------------------------------------------------------------------------------------------
set -euo pipefail

source $(dirname $0)/bash-environment-setup.sh
echo -e "${DEF_COLOR}### Setting variables..."

echo -e "${DEF_COLOR}### Working Directory : "${1}
WORKING_DIRECTORY=${1}

echo -e "${DEF_COLOR}### Terraform Config Directory : "${2}
TF_CONFIG_DIRECTORY=${2}

#download the terraform executable
echo -e "${DEF_COLOR}### Downloading terraform version : "${TERRAFORM_VERSION}
curl -SL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" --output terraform.zip

#validate the checksum and unzip to ENV
echo -e "${DEF_COLOR}### Validating Download and Unzipping ..."
echo "${TERRAFORM_DOWNLOAD_SHA} terraform.zip" | sha256sum -c -
/usr/bin/unzip "terraform.zip" -d ${TF_CONFIG_DIRECTORY}

echo -e "${DEF_COLOR}### List files in Config Directory ..."
cd ${TF_CONFIG_DIRECTORY}
pwd
ls -altr  

#validate the executable version on the agent 
echo -e "${DEF_COLOR}### Listing Terraform version in Config Directory ..."
pwd
./terraform --version

#clean up the .zip file
echo -e "${DEF_COLOR}### Removing ${WORKING_DIRECTORY}/terraform.zip ..."
rm ${WORKING_DIRECTORY}/terraform.zip