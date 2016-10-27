#!/usr/bin/env bash
if ! [ -z "$1" ]; then
  VMIP=$1
fi

if [ -z "$VMIP" ]; then
  echo "you must specify an IP address either by passing a parameter or setting $VMIP"
    exit 1
  fi

echo "Doing VM init on $VMIP"

ssh root@$VMIP <<EOF
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update -y && apt-get upgrade -y
apt-get install git git-review screen -y
reboot
EOF

ssh root@$VMIP
while test $? -gt 0
do
  sleep 5 # highly recommended - if it's in your local network, it can try an awful lot pretty quick...
  echo "Trying again..."
  ssh root@$VMIP 'echo host is up'
done

