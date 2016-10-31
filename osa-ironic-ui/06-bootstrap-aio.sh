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

echo "Bootstrapping AIO on $VMIP"

ssh root@$VMIP <<EOF 
cd /opt/openstack-ansible
./scripts/bootstrap-aio.sh | tee ~/bootstrap-aio
EOF

if ! [ -z "$CONFIGURE_SEARCHLIGHT" ]; then
  echo "Configuring searchlight"
  ssh root@$VMIP <<EOF2
    cp /opt/openstack-ansible/etc/openstack_deploy/conf.d/searchlight.yml.aio /etc/openstack_deploy/conf.d/searchlight.yml
EOF2
fi

footer $0
