#!/usr/bin/env bash
source "$(dirname "$0")/common_functions.sh"

#
# DOCUMENTS ARGUMENTS
#

usage() {
  echo -e "\nUsage: $0 -f -c -s <server-name> -b <osa-branch>" 1>&2
  echo -e "\nOptions:\n"
  echo -e "    -f    Fail fast"
  echo -e "    -s    Name of the new server, overriden by SRV_NAME enviroinment variable"
  echo -e "    -b    Branch of OSA to use.  Defaults to MASTER. Overriden by OSA_BRANCH variable"
  echo -e "\n"
    exit 1
  }

#
# GETS SCRIPT OPTIONS
#

setScriptOptions()
{
  CONFIGURE_SEARCHLIGHT=NO
  FAILFAST=NO
  while getopts "fs:l:b:" o; do
    case "${o}" in
      b)
        opt_b=${OPTARG}
        ;;

      f)
        FAILFAST=YES
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

  if [ -z ${SRV_NAME+x} ]; then
    if [[ ${opt_s} ]];then
      SRV_NAME=${opt_s}
    else
      usage
    fi
  fi

  if [ -z ${OSA_BRANCH+x} ]; then
    if [[ ${opt_b} ]];then
      OSA_BRANCH=${opt_b}
    else
      usage
    fi
  fi

}

#-----------------------------------------------------------------------------------------------------------------------
#
# Start of main scrip[t
#
#-----------------------------------------------------------------------------------------------------------------------
header $0
setScriptOptions "$@"


00-create-server.sh -s ${SRV_NAME}
if [ $? -ne 0 ]; then exit $? ; fi

#export VMIP=`rack servers instance get --name "$SRV_NAME" --fields=publicipv4 | cut -d $'\t' -f2`
#echo "VMIP=$VMIP"

#01-ship_key.sh -s ${SRV_NAME} && \
#02-osa_vm_init.sh && \
#03-clone-ansible.sh && \
#04-bootstrap-ansible.sh && \
#06-bootstrap-aio.sh && \
#07-run-playbooks.sh && \

getVMIP
export VMIP
echo "VMIP=${VMIP}"

echo "01-ship_key.sh -s ${SRV_NAME}" && \
01-ship_key.sh -s ${SRV_NAME} && \
echo "02-osa_vm_init.sh -s ${SRV_NAME}" && \
02-osa_vm_init.sh -s ${SRV_NAME} && \
echo "03-clone-ansible.sh -s ${SRV_NAME} -b ${OSA_BRANCH}" && \
03-clone-ansible.sh -s ${SRV_NAME} -b ${OSA_BRANCH} && \
env && \
echo "04-bootstrap-ansible.sh -s ${SRV_NAME}" && \
04-bootstrap-ansible.sh -s ${SRV_NAME} && \
echo "06-bootstrap-aio.sh -s ${SRV_NAME}" && \
06-bootstrap-aio.sh -s ${SRV_NAME} ${CONFIGURE_SEARCHLIGHT} && \
echo "07-run-playbooks.sh -s ${SRV_NAME}" && \
07-run-playbooks.sh -s ${SRV_NAME} && \

footer $0
