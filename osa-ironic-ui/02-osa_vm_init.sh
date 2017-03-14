#!/usr/bin/env bash
source "$(dirname "$0")/common_functions.sh"
#-----------------------------------------------------------------------------------------------------------------------
#
# DOCUMENTS ARGUMENTS
#
#-----------------------------------------------------------------------------------------------------------------------
usage() {
  echo -e "\nUsage: $0 -s <server-name>" 1>&2
  echo -e "\nOptions:\n"
  echo -e "    -s    Name of the new server, overridden by SRV_NAME environment variable"
  echo -e "\n"
    exit 1
  }

#-----------------------------------------------------------------------------------------------------------------------
#
# GETS SCRIPT OPTIONS
#
#-----------------------------------------------------------------------------------------------------------------------
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
    if [[ ${opt_s} ]];then
      SRV_NAME=${opt_s}
    else
      usage
    fi
  fi
}

initVM() {
    echo "Doing VM init on ${SRV_NAME}"
    ssh root@${SRV_NAME} <<EOF
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update -y && apt-get upgrade -y
apt-get install git git-review screen -y
reboot
EOF

    ssh root@${SRV_NAME}
    while test $? -gt 0
    do
      sleep 5 # highly recommended - if it's in your local network, it can try an awful lot pretty quick...
      echo "Trying again..."
      ssh root@${SRV_NAME} 'echo host is up'
    done
}


#-----------------------------------------------------------------------------------------------------------------------
#
# Start of main script
#
#-----------------------------------------------------------------------------------------------------------------------
header $0
setScriptOptions "$@"
initVM
footer $0
