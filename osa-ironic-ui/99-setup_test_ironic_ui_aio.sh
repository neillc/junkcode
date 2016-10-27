#######################################################################
#
# script to do the gunt work of building a working (ish) ironic aio 
# with the ironic-ui horizon plugin installed.
#
# Eventually this will become a patch agaainst OSA
#

# Clone OSA
git clone https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible
cd /opt/openstack-ansible

# Checkout a known working version because HEAD is often broken
# git checkout 13.1.2

# Adjust the openstack_services.yml file to add the ironic-ui git repo to the repos 
# that will be installed on the repo container
sed -i '/neutron_lbaas_dashboard_git_dest:/a\
\
\
## Horizon Ironic dashboard plugin      \
ironic_dashboard_git_repo: https://git.openstack.org/openstack/ironic-ui        \
ironic_dashboard_git_install_branch: 167f1be15c465b063258b236634f945d08ee9a3a # HEAD of "master" as of 17 May 2016      \
ironic_dashboard_git_dest: "/opt/ironic_dashboard_{{ ironic_dashboard_git_install_branch | replace('/', '_') }}"        \
' \
/opt/openstack-ansible/playbooks/defaults/repo_packages/openstack_services.yml

# Add the necessary bits to get an ironic conductor installed (thanks mrda!)
mkdir -p /etc/openstack_deploy/env.d/
mkdir -p /etc/openstack_deploy/conf.d
cp /opt/openstack-ansible/etc/openstack_deploy/env.d/ironic.yml /etc/openstack_deploy/env.d/ironic.yml
cp /opt/openstack-ansible/etc/openstack_deploy/conf.d/ironic.yml.aio    /etc/openstack_deploy/conf.d/ironic.yml

# Bootstrap ansible
./scripts/bootstrap-ansible.sh

# Add ironi-ui to the pip install packages fo the os_horizon role
sed -i '/^  - horizon$/a\
  - ironic-ui' \
/etc/ansible/roles/os_horizon/defaults/main.yml

# Activate the ironic_ui dashboard - note: this should be guarded by a 
# variable of some sort.
# Add to /etc/ansible/roles/os_horizon/tasks/horizon_post_install.yml\
# Note: Need to have a state condition like the neutron_lbaas\
sed -i '/^- name: Create horizon links$/i\
- name: Enable the horizon-ui-dashboard Horizon panel\
  file:\
    src: "{{ horizon_venv_lib_dir }}/ironic_ui/enabled/_2200_ironic.py"\
    path: "{{ horizon_venv_lib_dir }}/openstack_dashboard/local/enabled/_2200_ironic.py"\
    state: link\
  notify: Restart apache2\
  tags:\
    - horizon-configs\
' \
/etc/ansible/roles/os_horizon/tasks/horizon_post_install.yml

# Delete the line that seems to prevent the building of the horizon_venv
# Need to actually buiuld the venv to get a working ironic_ui
sed -i '/^    - horizon_get_venv | failed or horizon_developer_mode | bool$/d' \
/etc/ansible/roles/os_horizon/tasks/horizon_install.yml

# Continue with aio build
./scripts/bootstrap-aio.sh 
##./scripts/run-playbooks.sh

# Run playbooks manually
cd playbooks
openstack-ansible haproxy-install.yml
openstack-ansible setup-everything.yml

# Test ironic is working
UTIL=$(lxc-ls | grep utility)
lxc-attach -n $UTIL -- bash -c '. /root/openrc && ironic driver-list'

# You should now see a an ironic dashboard in horizon
# At this point it won't work because more ironic config needs to be done.
