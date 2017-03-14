#!/usr/bin/env bash
source "$(dirname "$0")/common_functions.sh"





header $0

function usage {
    echo "$0 VMIP/NAME FILENAME LOCALDIR REMOTEDIR"
    echo "e.g. $0 test-01 /home/neill/searchlight_changes.txt /home/neill/Projects/ /opt/openstack_ansible"
    exit 1
}

#######################################################################
#
# script to do the grunt work of building a working aio
#

if ! [ -z "$1" ]; then
  VMIP=$1
else
  usage
  exit 1
fi

if ! [ -z "$2" ]; then
  FILE=$2
else
  usage
fi

if ! [ -z "$3" ]; then
  LOCALDIR=$3
else
  usage
fi

if ! [ -z "$4" ]; then
  REMOTEDIR=$4
else
  usage
fi

echo "Copying changes to $VMIP (FILE=$FILE LOCAL=$LOCALDIR REMOTE=$REMOTEDIR"
copy_changes $FILE $LOCALDIR $REMOTEDIR $VMIP

footer $0
