#!/usr/bin/env bash
source "$(dirname "$0")/common_functions.sh"

#
# DOCUMENTS ARGUMENTS
#

usage() {
  echo -e "\nUsage: $0 -f -c -s <server-name> -b <osa-branch>" 1>&2
  echo -e "\nOptions:\n"
  echo -e "    -f    Fail fast"
  echo -e "    -c    configure searchlight"
  echo -e "    -l    Local directory (Required)"
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
  while getopts "fcs:l:b:" o; do
    case "${o}" in
      b)
        opt_b=${OPTARG}
        ;;

      c)
        CONFIGURE_SEARCHLIGHT=" -c "
        ;;

      f)
        FAILFAST=YES
        ;;

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

  if [ -z ${LOCALDIR+x} ]; then
    if [[ ${opt_l} ]];then
      LOCALDIR=${opt_l}
    fi
  fi
}

failWith() {
    echo $1 $2
    exit $2
}

#-----------------------------------------------------------------------------------------------------------------------
#
# Start of main scrip[t
#
#-----------------------------------------------------------------------------------------------------------------------

header $0
setScriptOptions $@
00-create-server.sh -s ${SRV_NAME}
if [ $? -ne 0 ]; then exit $? ; fi

getVMIP
export VMIP
echo "VMIP=$VMIP"

echo "01-ship_key.sh -s ${SRV_NAME}"
01-ship_key.sh -s ${SRV_NAME}
if [ $? -ne 0 ]; then
    failWith "01-ship_key.sh has failed with exit code $?" $?; fi

echo "02-osa_vm_init.sh -s ${SRV_NAME}"
02-osa_vm_init.sh -s ${SRV_NAME}
if [ $? -ne 0 ]; then failWith "02-osa_vm_init.sh has failed with exit code $?" $?; fi

echo "03-clone-ansible.sh -s ${SRV_NAME} -b ${OSA_BRANCH}"
03-clone-ansible.sh -s ${SRV_NAME} -b ${OSA_BRANCH}
if [ $? -ne 0 ]; then failWith "03-clone-ansible.sh has failed with exit code $?" $?; fi


if [[ ${LOCALDIR} ]]; then
    echo "04-bootstrap-ansible.sh -s ${SRV_NAME} -l ${LOCALDIR}"
    04-bootstrap-ansible.sh -s ${SRV_NAME} -l ${LOCALDIR}
    if [ $? -ne 0 ]; then failWith "04-bootstrap-ansible.sh has failed with exit code $?" $?; fi
else
    echo "04-bootstrap-ansible.sh -s ${SRV_NAME}"
    04-bootstrap-ansible.sh -s ${SRV_NAME}
    if [ $? -ne 0 ]; then failWith "04-bootstrap-ansible.sh has failed with exit code $?" $?; fi
fi

if [[ ${LOCALDIR} ]]; then
    echo "05-copy-changes.sh ${SRV_NAME} /home/neill/searchlight_changes.txt ${LOCALDIR} /opt/openstack-ansible"
    05-copy-changes.sh ${SRV_NAME} /home/neill/searchlight_changes.txt ${LOCALDIR} /opt/openstack-ansible
    RC=$?
    if [ ${RC} -ne 0 ]; then failWith "05-copy-changes.sh has failed with exit code ${RC}" ${RC}; fi
fi

echo "06-bootstrap-aio.sh -s ${SRV_NAME}"
06-bootstrap-aio.sh -s ${SRV_NAME} ${CONFIGURE_SEARCHLIGHT}
if [ $? -ne 0 ]; then failWith "06-bootstrap-aio.sh has failed with exit code $?" $?; fi

echo "07-run-playbooks.sh -s ${SRV_NAME}"
07-run-playbooks.sh -s ${SRV_NAME}
if [ $? -ne 0 ]; then failWith "07-run-playbooks.sh has failed with exit code $?" $?; fi

footer $0
