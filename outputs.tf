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
  value = data.external.supermarket_details.result["uid"]
}

output "supermarket_secret" {
  value = data.external.supermarket_details.result["secret"]
}

output "supermarket_redirect_uri" {
  value = data.external.supermarket_details.result["redirect_uri"]
}

output "validation_pem" {
  value = data.external.chef_server_details.result["validation_pem"]
}

output "validation_client_name" {
  value = data.external.chef_server_details.result["validation_client_name"]
}

output "client_pem" {
  value = data.external.chef_server_details.result["client_pem"]
}

output "base_url" {
  value = data.external.chef_server_details.result["base_url"]
}

output "org_url" {
  value = data.external.chef_server_details.result["org_url"]
}

output "node_name" {
  value = data.external.chef_server_details.result["node_name"]
}

output "secret_output" {
  value = data.external.frontend_secret_output.result
}
