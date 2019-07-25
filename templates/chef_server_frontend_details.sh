#!/bin/bash
set -eu -o pipefail
if [[ -f /etc/opscode/private-chef-secrets.json ]]; then
    veil_secret=$(jq -r '.veil.hasher.secret' /etc/opscode/private-chef-secrets.json)
    veil_salt=$(jq -r '.veil.hasher.salt' /etc/opscode/private-chef-secrets.json)
    cipher_key=$(jq -r '.veil.cipher.key' /etc/opscode/private-chef-secrets.json)
    cipher_iv=$(jq -r '.veil.cipher.iv' /etc/opscode/private-chef-secrets.json)
    credentials=$(jq -r '.veil.credentials' /etc/opscode/private-chef-secrets.json)
    VAR1=$(cat <<EOF
{
  "veil_secret":"$veil_secret",
  "veil_salt":"$veil_salt",
  "cipher_key":"$cipher_key",
  "cipher_iv":"$cipher_iv",
  "credentials":"$credentials"
}
EOF
  )
  else
      VAR1=$(cat <<EOF
{
  "veil_secret": "",
  "veil_salt":"",
  "cipher_key":"",
  "cipher_iv":"",
  "credentials":""
}
EOF
  )
fi
echo "${VAR1}" | jq '.'
