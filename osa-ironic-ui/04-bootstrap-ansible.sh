#!/usr/bin/env bash
source "$(dirname "$0")/common_functions.sh"
#-----------------------------------------------------------------------------------------------------------------------
#
# DOCUMENTS ARGUMENTS
#
#-----------------------------------------------------------------------------------------------------------------------
usage() {
  echo -e "\nUsage: $0 -s <server-name> -l <localdir>" 1>&2
  echo -e "\nOptions:\n"
  echo -e "    -s    Name of the new server, overridden by SRV_NAME environment variable"
  echo -e "    -l    Local directory to copy ansible-role-requirements.yml from overridden by LOCALDIR environment "
  echo -e "          variable. If not set no copying will be done"
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
  while getopts "s:l:" o; do
    case "${o}" in
      l)
        opt_l=${OPTARG}
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

  if [ -z ${LOCALDIR+x} ]; then
    if [[ ${opt_l} ]];then
      LOCALDIR=${opt_l}
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

bootstrapAnsible() {
    if [ ! -z "${LOCALDIR}" ]; then
        echo "Copying ansible-role-requirement to ${SRV_NAME}"
        REMOTE=root@${SRV_NAME}:/opt/openstack-ansible

        scp ${LOCALDIR}/openstack-ansible/ansible-role-requirements.yml \
            ${REMOTE}/ansible-role-requirements.yml
    fi


    echo "Bootstrapping ansible on $SRV_NAME"

    ssh root@$SRV_NAME <<EOF
cd /opt/openstack-ansible
# Bootstrap ansible
./scripts/bootstrap-ansible.sh | tee ~/bootstrap-ansible.log
EOF
}


#-----------------------------------------------------------------------------------------------------------------------
#
# Start of main script
#
#-----------------------------------------------------------------------------------------------------------------------

header $0
echo $0 $@
setScriptOptions "$@"
bootstrapAnsible
footer $0
