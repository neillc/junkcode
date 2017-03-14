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

delete-server ${SRV_NAME}

create_options="-s ${SRV_NAME}"

if [[ ${LOCALDIR} ]]; then
    create_options = "${create_options} -l ${LOCALDIR}"
fi

if [[ ${OSA_BRANCH} ]]; then
    create_options = "${create_options} -b ${OSA_BRANCH}"
fi

if [[ ${CONFIGURE_SEARCHLIGHT} ]]; then
    create_options = "${create_options} -c"
fi

if [[ ${FAILFAST} ]]; then
    create_options = "${create_options} -f"
fi


all-steps ${create_options}
