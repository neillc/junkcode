#!/usr/bin/env bash
if ! [ -z "$1" ]; then
  VMIP=$1
fi

if [ -z "$VMIP" ]; then
  echo "you must specify an IP address either by passing a parameter or setting $VMIP"
  exit 1
fi

echo "Cloning ansible to $VMIP"

ssh-keygen -f "$HOME/.ssh/known_hosts" -R $VMIP
cat $HOME/.ssh/id_rsa.pub  |  ssh -o "StrictHostKeyChecking no" root@$VMIP "cat >> .ssh/authorized_keys"
