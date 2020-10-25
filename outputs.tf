output "ip" {
  value = var.ip
}

output "ssh_user" {
  value = var.ssh_user_name
}

output "ssh_pass" {
  value = var.ssh_user_pass
}

output "supermarket_uid" {
  value = local.supermarket_details["uid"]
}

output "supermarket_secret" {
  value = local.supermarket_details["secret"]
}

output "supermarket_redirect_uri" {
  value = local.supermarket_details["redirect_uri"]
}

output "validation_pem" {
  value = local.chef_server_details["validation_pem"]
}

output "validation_client_name" {
  value = local.chef_server_details["validation_client_name"]
}

output "client_pem" {
  value = local.chef_server_details["client_pem"]
}

output "base_url" {
  value = local.chef_server_details["base_url"]
}

output "org_url" {
  value = local.chef_server_details["org_url"]
}

output "node_name" {
  value = local.chef_server_details["node_name"]
}

output "secret_output" {
  value = local.frontend_secrets
}
