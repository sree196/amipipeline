#!/bin/bash 
set -x
set -e
set -o pipefail

#
# General definitions
#
declare -r SUDO_CMD="sudo -E" # Save environment variables if they exist

#
# Clean-up operations go down here
#
$SUDO_CMD yum install yum-utils
$SUDO_CMD package-cleanup --leaves
$SUDO_CMD yum remove `package-cleanup --leaves`
$SUDO_CMD yum clean all
