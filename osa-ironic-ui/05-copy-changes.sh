#!/usr/bin/env bash
source "$(dirname "$0")/common_functions.sh"
header $0


#######################################################################
#
# script to do the grunt work of building a working aio
#
if ! [ -z "$1" ]; then
  VMIP=$1
fi

if [ -z "$VMIP" ]; then
  echo "you must specify an IP address either by passing a parameter or setting \$VMIP"
  exit 1
fi

if ! [ -z "$2" ]; then
  LOCALDIR=$2
fi

if [ -z "$LOCALDIR" ]; then
  echo "you must specify the local directory passing a parameter or setting \$LOCALDIR"
  exit 1
fi


echo "Copying changes to $VMIP"

rsync -avz --exclude=".git" \
  $LOCALDIR/openstack-ansible-os_searchlight/ \
  root@$VMIP:/etc/ansible/roles/os_searchlight

#rsync -avz --exclude=".git" --exclude=".tox" --exclude="doc" \
#  --exclude="*pyc" $LOCALDIR/openstack-ansible root@$VMIP:/opt/

REMOTE=root@$VMIP:/opt/openstack-ansible

scp $LOCALDIR/openstack-ansible/etc/openstack_deploy/conf.d/searchlight.yml.aio \
  $REMOTE/etc/openstack_deploy/conf.d/searchlight.yml.aio

scp $LOCALDIR/openstack-ansible/playbooks/inventory/env.d/searchlight.yml \
  $REMOTE/playbooks/inventory/env.d/searchlight.yml

scp $LOCALDIR/openstack-ansible/playbooks/os-searchlight-install.yml \
  $REMOTE/playbooks/os-searchlight-install.yml

scp $LOCALDIR/openstack-ansible/playbooks/setup-openstack.yml \
  $REMOTE/playbooks/setup-openstack.yml

scp $LOCALDIR/openstack-ansible/playbooks/inventory/group_vars/searchlight_all.yml \
  $REMOTE/playbooks/inventory/group_vars/searchlight_all.yml

echo scp $LOCALDIR/openstack-ansible/etc/openstack_deploy/user_secrets.yml \
  $REMOTE/etc/openstack_deploy/user_secrets.yml

scp $LOCALDIR/openstack-ansible/etc/openstack_deploy/user_secrets.yml \
  $REMOTE/etc/openstack_deploy/user_secrets.yml

footer $0
