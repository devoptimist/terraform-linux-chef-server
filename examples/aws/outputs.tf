output "node_name" {
  value = module.chef_server.node_name
}

output "org_url" {
  value = module.chef_server.org_url
}

output "private_ip" {
  value = module.instance["chef"].private_ip[0]
}
