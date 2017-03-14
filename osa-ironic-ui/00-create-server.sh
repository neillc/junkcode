#!/usr/bin/env bash
#
# DOCUMENTS ARGUMENTS
#

usage() {
  echo -e "\nUsage: $0 -s <server-name>" 1>&2
  echo -e "\nOptions:\n"
  echo -e "    -s    Name of the new server, overriden by SRV_NAME environment variable"
  echo -e "\n"
    exit 1
  }

#
# GETS SCRIPT OPTIONS 
#

setScriptOptions()
{
  while getopts "s:" o; do
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

createServer() {
  srv_exists=`rack servers instance list | grep "^[a-f0-9-]\+\s\+${SRV_NAME}\s\+"`
  if [[ "${srv_exists}" != "" ]]; then
    echo "Server already exists"
    exit 1
  fi

  rack servers instance create --name="$SRV_NAME" --flavor-id=io1-15 --block-device="source-type=image,source-id=1d3ea64f-1ead-4042-8cb6-8ceb523b6149,destination-type=volume,volume-size=150" --keypair=neill

  STATUS=`rack servers instance get --name "$SRV_NAME" --fields=status`
  while [ "$STATUS" == "Status	BUILD" ]; do
    echo "status is still: $STATUS, sleeping for 15 seconds" 
    sleep 15
    STATUS=`rack servers instance get --name "$SRV_NAME" --fields=status`
  done
  
  echo "Server Ready"
}

adjustSSHConfig() {
  getVMIP

  sed -i.bak '/host '$SRV_NAME'/ {N;N;d;}' $HOME/.ssh/config
  
  echo "Add the new host to .ssh/config"
  cat >> $HOME/.ssh/config <<EOF
  host $SRV_NAME
    hostname $VMIP
    user root
EOF

  echo Remove the host key if it is already in known_hosts
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R $VMIP

  echo Touch the server to remove StrictHostKeyChecking warnings
  ssh -o "StrictHostKeyChecking no" root@$VMIP "echo Remove StrictHostKeyChecking warning"
}

setScriptOptions "$@"
source "$(dirname "$0")/common_functions.sh"
header $0
createServer
adjustSSHConfig
footer $0
