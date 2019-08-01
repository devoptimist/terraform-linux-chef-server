locals {
  instance_count    = var.instance_count # length(var.ips) <- does not work??
  starter_pack_user = length(keys(var.orgs)) != 0 ? var.orgs[keys(var.orgs)[0]]["admins"][0] : ""
  starter_pack_org  = length(keys(var.orgs)) != 0 ? keys(var.orgs)[0] : ""
  script            = templatefile("${path.module}/templates/starter_kit.sh", {
    starter_pack_user          = local.starter_pack_user,
    starter_pack_org           = local.starter_pack_org,
    starter_pack_knife_rb_path = var.starter_pack_knife_rb_path,
    ssh_user_name              = var.ssh_user_name,
    starter_pack_location      = var.starter_pack_location
  })

  dna = [
    for ip in var.ips :
    {
      "chef_server_wrapper" = {
        "details_script_path"   = var.data_source_script_path,
        "frontend_script_path"  = var.frontend_script_path,
        "channel"               = var.channel,
        "version"               = var.install_version,
        "accept_license"        = var.accept_license,
        "config"                = var.config,
        "addons"                = var.addons,
        "supermarket_url"       = length(var.supermarket_url) != 0 ? var.supermarket_url[index(var.ips, ip)] : "" ,
        "fqdn"                  = length(var.fqdns) != 0 ? var.fqdns[index(var.ips, ip)] : "",
        "cert"                  = length(var.certs) != 0 ? var.certs[index(var.ips, ip)] : "",
        "cert_key"              = length(var.cert_keys) != 0 ? var.cert_keys[index(var.ips, ip)] : "",
        "starter_pack_user"     = local.starter_pack_user,
        "starter_pack_org"      = local.starter_pack_org,
        "chef_users"            = var.users,
        "chef_orgs"             = var.orgs,
        "tmp_path"              = var.tmp_path,
        "force"                 = var.force_run
      }
    }
  ]
  module_inputs = [
    for ip in var.ips :
    {
      "chef_server_wrapper" = {
        "data_collector_url"   = length(var.data_collector_url) != 0 ? var.data_collector_url[index(var.ips, ip)] : "",
        "data_collector_token" = length(var.data_collector_token) != 0 ? var.data_collector_token[index(var.ips, ip)] : "",
        "config_block"         = length(keys(var.config_block)) != 0 ? var.config_block : {},
        "frontend_secrets"     = length(var.frontend_secrets) != 0 ? element(var.frontend_secrets, 0) : null
      }
    }
  ]
}

module "chef_server_build" {
  source            = "devoptimist/policyfile/chef"
  version           = "0.0.2"
  ips               = var.ips
  instance_count    = local.instance_count
  dna               = local.dna
  module_inputs     = local.module_inputs
  cookbooks         = var.cookbooks
  runlist           = var.runlist
  user_name         = var.ssh_user_name
  user_pass         = var.ssh_user_pass
  user_private_key  = var.ssh_user_private_key
}

data "external" "supermarket_details" {
  count = local.instance_count
  program = ["bash", "${path.module}/files/supermarket_data_source.sh"]
  depends_on = ["module.chef_server_build"]

  query = {
    ssh_user              = var.ssh_user_name
    ssh_key               = var.ssh_user_private_key
    ssh_pass              = var.ssh_user_pass
    chef_server_ip        = var.ips[count.index]
  }
}

resource "null_resource" "starter_pack" {
  count = length(keys(var.users)) != 0 && length(keys(var.orgs)) != 0 ? var.instance_count : 0

  connection {
    user        = var.ssh_user_name
    password    = var.ssh_user_pass
    host        = var.ips[count.index]
  }

  provisioner "file" {
    content     = local.script
    destination = "${var.tmp_path}/starter_kit.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash ${var.tmp_path}/starter_kit.sh"
    ]
  }
  depends_on = ["module.chef_server_build"]
}

data "external" "chef_server_details" {
  count = local.instance_count
  program = ["bash", "${path.module}/files/data_source.sh"]
  depends_on = ["module.chef_server_build"]

  query = {
    ssh_user      = var.ssh_user_name
    ssh_key       = var.ssh_user_private_key
    ssh_pass      = var.ssh_user_pass
    target_ip     = var.ips[count.index]
    target_script = var.data_source_script_path
  }
}

data "external" "frontend_secret_output" {
  count = local.instance_count
  program = ["bash", "${path.module}/files/data_source.sh"]
  depends_on = ["module.chef_server_build"]

  query = {
    ssh_user      = var.ssh_user_name
    ssh_key       = var.ssh_user_private_key
    ssh_pass      = var.ssh_user_pass
    target_ip     = var.ips[count.index]
    target_script = var.frontend_script_path
  }
}
