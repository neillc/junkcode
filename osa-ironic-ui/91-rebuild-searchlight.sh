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
cd /opt/openstack-ansible/playbooks/
CONTAINER=\`lxc-ls -f | grep searchlight | cut -f1 -d" "\`
openstack-ansible lxc-containers-destroy.yml --limit \$CONTAINER -e "force_containers_destroy=true" -e "force_containers_data_destroy=true"
openstack-ansible lxc-containers-create.yml --limit \$CONTAINER
openstack-ansible os-searchlight-install.yml | tee ~/rebuild-searchligh.log
EOF
