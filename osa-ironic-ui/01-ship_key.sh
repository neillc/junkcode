#!/usr/bin/env bash

#
# DOCUMENTS ARGUMENTS
#

usage() {
  echo -e "\nUsage: $0 -s <server-name> -i <server-ip>" 1>&2
  echo -e "\nOptions:\n"
  echo -e "    -s    Name of the new server, overridden by SRV_NAME environment variable"
  echo -e "\n"
    exit 1
  }

#
# GETS SCRIPT OPTIONS 
#

setScriptOptions()
{
  while getopts "s:i:" o; do
    case "${o}" in
      s)
        opt_s=${OPTARG}
        ;;
      *)
        usage
        ;;
    esac
  done
  shift $((OPTIND-1))

  if [ -z ${SRV_NAME+x} ]; then
    if [[ $opt_s ]];then
      SRV_NAME=$opt_s
    else
      usage
    fi
  fi
}

copySSHKey() {
  echo "Copying SSH key to $SRV_NAME($VMIP)"
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R $VMIP
  cat $HOME/.ssh/id_rsa.pub  |  ssh -o "StrictHostKeyChecking no" root@$VMIP "cat >> .ssh/authorized_keys"
}

#----------------------------------------------------------------------
# 
# Start of main script
#
#----------------------------------------------------------------------
source "$(dirname "$0")/common_functions.sh"
setScriptOptions "$@"
getVMIP
header $0
copySSHKey
footer $0
