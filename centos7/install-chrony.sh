#!/bin/bash 
set -x
set -e
set -o pipefail

#
# General definitions
#
declare -r SUDO_CMD="sudo -E" # Save environment variables if they exist
declare -r PACKAGES_TO_REMOVE=(
  "ntp"
)
declare -r PACKAGES_TO_INSTALL=(
  "chrony"
)

#
# General work towards functioning system goes here
#
$SUDO_CMD yum -y remove ${PACKAGES_TO_REMOVE[@]}
$SUDO_CMD yum -y update
$SUDO_CMD yum -y install ${PACKAGES_TO_INSTALL[@]} >/dev/null
$SUDO_CMD /bin/sed -i '1iserver 169.254.169.123 prefer iburst' /etc/chrony.conf
$SUDO_CMD /bin/sed -i '/^pool/d' /etc/chrony.conf
$SUDO_CMD systemctl enable chronyd
$SUDO_CMD systemctl restart chronyd
sleep 5
chronyc sources
chronyc tracking
