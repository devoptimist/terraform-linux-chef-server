locals {
  starter_pack_user      = length(keys(var.orgs)) != 0 ? var.orgs[keys(var.orgs)[0]]["admins"][0] : ""
  starter_pack_org       = length(keys(var.orgs)) != 0 ? keys(var.orgs)[0] : ""
  consul_policyfile_name = "consul"

  tmp_path        = "${var.tmp_path}/${var.policyfile_name}"
  consul_tmp_path = "${var.tmp_path}/${local.consul_policyfile_name}"

  consul_populate_script_lock_file = "${local.consul_tmp_path}/consul_populate.lock"

  consul_populate_script = templatefile("${path.module}/templates/consul_populate_script", {
    tmp_path        = local.tmp_path
    consul_tmp_path = local.consul_tmp_path
    consul_port     = var.consul_port
    lock_file       = local.consul_populate_script_lock_file
  })

  code = var.automate_module != "" ? var.automate_module : jsonencode({ "data_collector_url" = var.data_collector_url, "data_collector_token" = var.data_collector_token })

  data_collector_url   = jsondecode(local.code)["data_collector_url"]
  data_collector_token = jsondecode(local.code)["data_collector_token"]

  dna = {
    "chef_server_wrapper" = {
      "channel"              = var.channel,
      "version"              = var.install_version,
      "accept_license"       = var.accept_license,
      "config"               = var.config,
      "addons"               = var.addons,
      "supermarket_url"      = var.supermarket_url,
      "fqdn"                 = var.fqdn,
      "cert"                 = var.cert,
      "cert_key"             = var.cert_key,
      "starter_pack_user"    = local.starter_pack_user,
      "starter_pack_org"     = local.starter_pack_org,
      "chef_users"           = var.users,
      "chef_orgs"            = var.orgs,
      "tmp_path"             = local.tmp_path,
      "force"                = var.force_run
      "data_collector_url"   = local.data_collector_url,
      "data_collector_token" = local.data_collector_token,
      "config_block"         = length(keys(var.config_block)) != 0 ? var.config_block : {},
      "frontend_secrets"     = length(var.frontend_secrets) != 0 ? element(var.frontend_secrets, 0) : null
    }
  }
}

module "chef_server_build" {
  source           = "srb3/policyfile/chef"
  version          = "0.13.2"
  ip               = var.ip
  dna              = local.dna
  cookbooks        = var.cookbooks
  runlist          = var.runlist
  user_name        = var.ssh_user_name
  user_pass        = var.ssh_user_pass
  user_private_key = var.ssh_user_private_key
  policyfile_name  = var.policyfile_name
  timeout          = var.timeout
}

module "consul" {
  source                    = "srb3/consul/util"
  version                   = "0.13.4"
  ip                        = var.ip
  user_name                 = var.ssh_user_name
  user_private_key          = var.ssh_user_private_key
  populate_script           = local.consul_populate_script
  populate_script_lock_file = local.consul_populate_script_lock_file
  datacenter                = var.consul_datacenter
  linux_tmp_path            = var.tmp_path
  policyfile_name           = local.consul_policyfile_name
  port                      = var.consul_port
  log_level                 = var.consul_log_level
  depends_on                = [module.chef_server_build]
}

data "http" "chef_server_details" {
  url = "http://${var.ip}:${var.consul_port}/v1/kv/chef-server-details?raw"
  request_headers = {
    Accept = "application/json"
  }
  depends_on = [module.consul]
}

data "http" "frontend_secrets" {
  url = "http://${var.ip}:${var.consul_port}/v1/kv/frontend-secrets?raw"
  request_headers = {
    Accept = "application/json"
  }
  depends_on = [data.http.chef_server_details]
}

data "http" "supermarket_details" {
  url = "http://${var.ip}:${var.consul_port}/v1/kv/supermarket?raw"
  request_headers = {
    Accept = "application/json"
  }
  depends_on = [data.http.frontend_secrets]
}

locals {
  chef_server_details = jsondecode(data.http.chef_server_details.body)
  frontend_secrets    = jsondecode(data.http.frontend_secrets.body)
  supermarket_details = jsondecode(data.http.supermarket_details.body)
}
