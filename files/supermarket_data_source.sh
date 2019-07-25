#!/bin/bash
set -eu -o pipefail


eval "$(jq -r '@sh "export ssh_user=\(.ssh_user) ssh_key=\(.ssh_key) ssh_pass=\(.ssh_pass) chef_server_ip=\(.chef_server_ip)"')"

ssh-keyscan -H ${chef_server_ip} >> ~/.ssh/known_hosts 2>/dev/null

if [[ ! -z "${ssh_key}" ]]; then
  if ssh -i ${ssh_key} ${ssh_user}@${chef_server_ip} "sudo cat /etc/opscode/oc-id-applications/supermarket.json" &>/dev/null; then
    ssh -i ${ssh_key} ${ssh_user}@${chef_server_ip} "sudo cat /etc/opscode/oc-id-applications/supermarket.json | jq 'del(.scopes)'" 
  else
    ssh -i ${ssh_key} ${ssh_user}@${chef_server_ip} "echo '{\"name\": \"\",\"uid\": \"\",\"secret\":\"\",\"redirect_uri\":\"\"}' | jq '.'"
  fi
else 
  if ! hash sshpass; then
    echo "must install sshpass"
    exit 1
  else
    if sshpass -p ${ssh_pass} ssh ${ssh_user}@${chef_server_ip} "sudo cat /etc/opscode/oc-id-applications/supermarket.json" &>/dev/null; then
      sshpass -p ${ssh_pass} ssh ${ssh_user}@${chef_server_ip} "sudo cat /etc/opscode/oc-id-applications/supermarket.json | jq 'del(.scopes)'" 
    else
      sshpass -p ${ssh_pass} ssh ${ssh_user}@${chef_server_ip} "echo '{\"name\": \"\",\"uid\": \"\",\"secret\":\"\",\"redirect_uri\":\"\"}' | jq '.'"
    fi
  fi
fi
