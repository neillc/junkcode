echo $1                                                                                                                                                                                                           
                                                                                                                                                                                                                  
ssh root@$1 <<EOF 
apt-get install git-review
git clone https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible
git config --global --add gitreview.username "neillc"
cd /opt/openstack-ansible
EOF
