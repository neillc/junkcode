#!/usr/bin/env bash
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

echo "Running playbooks on $VMIP"

ssh root@$VMIP <<EOF 
cd /opt/openstack-ansible
./scripts/run-playbooks.sh | tee ~/run-playbooks.log
EOF
