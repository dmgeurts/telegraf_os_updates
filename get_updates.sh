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
loc_domain="ipnexia.com"

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
  updates=$(apt-get -s dist-upgrade -V | grep ^Inst)
  COLUMN=4
  # Create empty array
  declare -A type
  # Fill associative array
  while read -a line; do
    type[${line[$COLUMN]:-(empty)}]=$((type[${line[$COLUMN]:-(empty)}]+1));
  done <<< "$updates"
elif [ "$method" == "dnf" ]; then
  echo "dnf work not finished yet"
  exit 1
fi

# Feed data to Telegraf
if [ ${#type[@]} -eq 0 ]; then
  updates=0
  security=0
  local_repo=0
else
  for key in ${!type[@]}; do
    if [[ "key" == *"$loc_domain"* ]]; then
      local_repo=${type[$key]}
    elif [[ "key" == *"-security"* ]]; then
      security=${type[$key]}
    elif [[ "key" == *"-updates"* ]]; then
      updates=${type[$key]}
    fi
  done
fi
printf 'linux_updates updates=%di,security=%di,local=%di\n' "$updates" "$security" "$local_repo"

# EOF
