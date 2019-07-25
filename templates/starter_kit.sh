#!/bin/bash
    
mkdir -p /tmp/chef-repo/.chef
mkdir -p /tmp/chef-repo/cookbooks
mkdir -p /tmp/chef-repo/policies
sudo cp /etc/opscode/users/${starter_pack_user}.pem /tmp/chef-repo/.chef/
sudo cp /etc/opscode/orgs/${starter_pack_org}-validation.pem /tmp/chef-repo/.chef/
cp ${starter_pack_knife_rb_path} /tmp/chef-repo/.chef/
sudo chown -R ${ssh_user_name}:${ssh_user_name} /tmp/chef-repo
tar czf ${starter_pack_location} -C /tmp/ chef-repo/
