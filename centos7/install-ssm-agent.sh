#!/bin/bash
set -x
set -e
set -o pipefail

#
# General definitions
#
declare -r SUDO_CMD="sudo -E" # Save environment variables if they exist

#
# General work towards functioning system goes here
#
$SUDO_CMD cd /tmp
$SUDO_CMD yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
$SUDO_CMD yum -y update 
$SUDO_CMD systemctl start amazon-ssm-agent
$SUDO_CMD systemctl enable amazon-ssm-agent
