#!/usr/bin/env bash
source "$(dirname "$0")/common_functions.sh"

#-----------------------------------------------------------------------------------------------------------------------
#
# DOCUMENTS ARGUMENTS
#
#-----------------------------------------------------------------------------------------------------------------------
usage() {
  echo -e "\nUsage: $0 -s <server-name> -c" 1>&2
  echo -e "\nOptions:\n"
  echo -e "    -s    Name of the new server, overridden by SRV_NAME environment variable"
  echo -e "    -c    configure the searchlight role "
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
  CONFIGURE_SEARCHLIGHT="NO"

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

runPlayBooks() {
    echo "Running playbooks on ${SRV_NAME}"

    ssh root@${SRV_NAME} <<EOF
    cd /opt/openstack-ansible
    ./scripts/run-playbooks.sh | tee ~/run-playbooks.log
EOF
}

header $0
setScriptOptions "$@"
runPlayBooks
footer $0
