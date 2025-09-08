#!/usr/bin/env bash
set -euo pipefail

echo "### Setting variables..."
echo "### Working Directory : "${1}
WORKING_DIRECTORY=${1}

echo "### Terraform Config Directory : "${2}
TF_CONFIG_DIRECTORY=${2}

echo "### Changing to the working directory..."
cd ${WORKING_DIRECTORY}

echo "### Display the terraform version in the working directory..."
${WORKING_DIRECTORY}/terraform --version

echo "### [tfplan] : "${BUILD_BUILDNUMBER}.tfplan
echo "### [tfdir]  : "${TF_CONFIG_DIRECTORY}
echo "### [cmd]    : terraform show -chdir=data-platform-v4/subscription/test-legacy-dap-01/dev -json ${BUILD_BUILDNUMBER}.tfplan"

echo "### Calling terraform show, passing the [tfdir] and binary [tfplan], output is JSON"
set -x 
export TF_LOG=TRACE
echo "### Printing current directory..."
pwd

terraform show -chdir=data-platform-v4/subscription/dap-development/dev -json ${BUILD_BUILDNUMBER}.tfplan

# > ${BUILD_BUILDNUMBER}.tfplan.json
