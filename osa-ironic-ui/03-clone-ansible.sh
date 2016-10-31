#!/usr/bin/env bash
source "$(dirname "$0")/common_functions.sh"
header $0

#######################################################################
#
# script to do the gunt work of building a working aio
#

if ! [ -z "$1" ]; then
  VMIP=$1
fi

if [ -z "$VMIP" ]; then
  echo "you must specify an IP address either by passing a parameter or setting $VMIP"
  exit 1
fi

echo "Cloning ansible to $VMIP"
                                                                                                                                                                                                                  
ssh root@$VMIP <<EOF 

# Clone OSA
git clone https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible


# Checkout a known working version because HEAD is often broken
# git checkout 13.1.2

EOF

footer $0
