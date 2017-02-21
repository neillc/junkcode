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

echo "Copying ansible-role-requirement to $VMIP"
if [ -z "$LOCALDIR" ]; then
  echo "you must specify the local directory passing a parameter or setting \$LOCALDIR"
  exit 1
fi

REMOTE=root@$VMIP:/opt/openstack-ansible

if [ -z "$VANILLA" ]; then
    scp $LOCALDIR/openstack-ansible/ansible-role-requirements.yml \
        $REMOTE/ansible-role-requirements.yml
fi

echo "Bootstrapping ansible on $VMIP"

ssh root@$VMIP <<EOF
cd /opt/openstack-ansible
# Bootstrap ansible
./scripts/bootstrap-ansible.sh | tee ~/bootstrap-ansible.log
EOF


footer $0
