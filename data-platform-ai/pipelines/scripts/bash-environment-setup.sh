#!/usr/bin/env bash
# -------------------------------------------------------------------------------------------------------
# Environment
# -------------------------------------------------------------------------------------------------------
# Set common variables in this script.
# This script is called when required.
#
# -------------------------------------------------------------------------------------------------------
set -euo pipefail

# Define colour variables
export NC='\033[0m' # No Colour
export RED='\033[0;31m'
export YELLOW='\033[0;33m'
export WHITE='\033[0;37m'
export CYAN='\033[0;36m'
export GREEN='\033[0;32m'

export DEF_COLOR=${CYAN}