#!/bin/bash
set -eu -o pipefail
%{ if chef_org != "" && chef_user != "" }
  client_pem=$(sed ':a;N;$!ba;s/\n/\\n/g' /tmp/chef-repo/.chef/${chef_user}.pem)
  validation_pem=$(sed ':a;N;$!ba;s/\n/\\n/g' /tmp/chef-repo/.chef/${chef_org}-validation.pem)
  VAR1=$(cat <<EOF
{
  "starter_pack": "${starter_pack_location}",
  "validation_pem": "${validation_pem}",
  "validation_client_name": "${chef_org}-validation",
  "client_pem": "${client_pem}",
  "chef_server_url": "https://${chef_server_ip}/organisations/${chef_org}",
  "node_name": "${chef_user}"
}
EOF
  )
%{ else }
  VAR1=$(cat <<EOF
{
  "starter_pack": "",
  "validation_pem": "",
  "validation_client_name": "",
  "client_pem": "",
  "chef_server_url": "",
  "node_name": ""
}
EOF
  )
%{ endif }

echo "${VAR1}" | jq '.'
