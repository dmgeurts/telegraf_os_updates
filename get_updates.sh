#!/bin/bash
# Script for Telegraf to grab the pending updates
# Author: Djerk Geurts <djerk@maizymoo.com>
# Version: 2023-06-28 v1.00
#
# Run (as root,) from Telegraf

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Variables
loc_domain="domain.local"
updates=0
security=0
local_repo=0

# Detect the OS type
declare $(cat /etc/os-release | grep ^ID)
if [ "$ID_LIKE" == "debian" ]; then
  method="apt"
elif [ "ID" == "fedora" ]; then
  ID_LIKE="$ID"
  method="dnf"
fi

# Grab available updates
if [ "$method" == "apt" ]; then
  apt update > /dev/null 2>&1
  installs=$(apt-get -s dist-upgrade -V | grep ^Inst)
  updates=$(grep "\-updates" <<< "$installs" | wc -l)
  security=$(grep "\-security" <<< "$installs" | wc -l)
  local_repo=$(grep "$loc_domain" <<< "$installs" | wc -l)
elif [ "$method" == "dnf" ]; then
  echo "dnf work not finished yet"
  exit 1
fi

# Feed data to Telegraf
printf 'linux_updates updates=%di,security=%di,local=%di\n' "$updates" "$security" "$local_repo"

# EOF
