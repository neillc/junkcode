#!/usr/bin/env bash
source "$(dirname "$0")/common_functions.sh"

#-----------------------------------------------------------------------------------------------------------------------
#
# DOCUMENTS ARGUMENTS
#
#-----------------------------------------------------------------------------------------------------------------------
usage() {
  echo -e "\nUsage: $0 -s <server-name> -b <osa_branch>" 1>&2
  echo -e "\nOptions:\n"
  echo -e "    -s    Name of the new server, overriden by SRV_NAME environment variable"
  echo -e "    -b    Branch of OSA to use.  Defaults to MASTER. Overriden by OSA_BRANCH variable"
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
  while getopts "s:b:" o; do
    case "${o}" in
      b)
        opt_b=${OPTARG}
        ;;

      s)
        opt_s=${OPTARG}
        ;;

      *)
        usage
        ;;
    esac
  done
  shift $((OPTIND-1))

  if [ -z ${OSA_BRANCH+x} ]; then
    if [[ ${opt_b} ]];then
      OSA_BRANCH=${opt_b}
    else
      OSA_BRANCH="master"
    fi
  fi

  if [ -z ${SRV_NAME+x} ]; then
    if [[ ${opt_s} ]];then
      SRV_NAME=${opt_s}
    else
      usage
    fi
  fi
}

cloneAnsible() {
    echo "Cloning ansible to ${SRV_NAME}"
    ssh root@${SRV_NAME} <<EOF

# Clone OSA
git clone https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible

cd /opt/openstack-ansible

# Checkout a known working version because HEAD is often broken
echo "Checking out ${OSA_BRANCH}"
git checkout ${OSA_BRANCH}

EOF
}


#-----------------------------------------------------------------------------------------------------------------------
#
# Start of main script
#
#-----------------------------------------------------------------------------------------------------------------------
header $0
setScriptOptions $@
cloneAnsible
footer $0
