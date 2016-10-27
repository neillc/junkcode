#!/usr/bin/env bash

export LOCALDIR=/Users/neill/Dropbox/Projects/
export CONFIGURE_SEARCHLIGHT=YES

if ! [ -z ${1+x} ]; then
  export SRV_NAME=${1}
fi

if [ -z "$SRV_NAME" ]; then
  echo "you must specify a server name either by passing a parameter or setting SRV_NAME"
  exit 1
fi

00-create-server $SRV_NAME

export VMIP=`rack servers instance get --name "$SRV_NAME" --fields=publicipv4 | cut -d $'\t' -f2`
echo "VMIP=$VMIP"

01-ship_key.sh
02-osa_vm_init.sh
03-clone-ansible.sh
04-bootstrap-ansible.sh
05-copy-changes.sh
06-bootstrap-aio.sh
07-run-playbooks.sh
