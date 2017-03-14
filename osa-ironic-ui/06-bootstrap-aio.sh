#!/usr/bin/env bash
set -xeu

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

  while getopts "s:c" o; do
    case "${o}" in
      s)
        opt_s=${OPTARG}
        ;;

      c)
        CONFIGURE_SEARCHLIGHT="YES"
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

bootstrapAIO() {
    echo "Bootstrapping AIO on ${SRV_NAME}"

    ssh root@${SRV_NAME} <<EOF
        set -xeu
        cd /opt/openstack-ansible
        ./scripts/bootstrap-aio.sh | tee ~/bootstrap-aio
EOF

    if [ "$CONFIGURE_SEARCHLIGHT" == "YES" ]; then
      echo "Configuring searchlight"
      ssh root@${SRV_NAME} <<EOF2
        cp /opt/openstack-ansible/etc/openstack_deploy/conf.d/searchlight.yml.aio \
           /etc/openstack_deploy/conf.d/searchlight.yml
EOF2
fi
}

header $0
setScriptOptions "$@"
bootstrapAIO
footer $0
