locals {
  starter_pack_user = length(keys(var.orgs)) != 0 ? var.orgs[keys(var.orgs)[0]]["admins"][0] : ""
  starter_pack_org  = length(keys(var.orgs)) != 0 ? keys(var.orgs)[0] : ""
  script            = templatefile("${path.module}/templates/starter_kit.sh", {
    starter_pack_user          = local.starter_pack_user,
    starter_pack_org           = local.starter_pack_org,
    starter_pack_knife_rb_path = var.starter_pack_knife_rb_path,
    ssh_user_name              = var.ssh_user_name,
    starter_pack_location      = var.starter_pack_location
  })
  code = var.automate_module != "" ? var.automate_module : jsonencode({"data_collector_url" = var.data_collector_url, "data_collector_token" = var.data_collector_token})

  data_collector_url = jsondecode(local.code)["data_collector_url"]
  data_collector_token = jsondecode(local.code)["data_collector_token"]

  dna = {
    "chef_server_wrapper" = {
      "details_script_path"   = var.data_source_script_path,
      "frontend_script_path"  = var.frontend_script_path,
      "channel"               = var.channel,
      "version"               = var.install_version,
      "accept_license"        = var.accept_license,
      "config"                = var.config,
      "addons"                = var.addons,
      "supermarket_url"       = var.supermarket_url,
      "fqdn"                  = var.fqdn,
      "cert"                  = var.cert,
      "cert_key"              = var.cert_key,
      "starter_pack_user"     = local.starter_pack_user,
      "starter_pack_org"      = local.starter_pack_org,
      "chef_users"            = var.users,
      "chef_orgs"             = var.orgs,
      "tmp_path"              = var.tmp_path,
      "force"                 = var.force_run
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

data "external" "supermarket_details" {
  program = ["bash", "${path.module}/files/supermarket_data_source.sh"]
  depends_on = ["module.chef_server_build"]

  query = {
    ssh_user              = var.ssh_user_name
    ssh_key               = var.ssh_user_private_key
    ssh_pass              = var.ssh_user_pass
    chef_server_ip        = var.ip
  }
}

resource "null_resource" "starter_pack" {
  count = length(keys(var.users)) != 0 && length(keys(var.orgs)) != 0 ? 1 : 0

  connection {
    user        = var.ssh_user_name
    password    = var.ssh_user_pass
    private_key = var.ssh_user_private_key != "" ? file(var.ssh_user_private_key) : null
    host        = var.ip
    timeout     = var.timeout
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
  program = ["bash", "${path.module}/files/data_source.sh"]
  depends_on = ["module.chef_server_build"]

  query = {
    ssh_user      = var.ssh_user_name
    ssh_key       = var.ssh_user_private_key
    ssh_pass      = var.ssh_user_pass
    target_ip     = var.ip
    target_script = var.data_source_script_path
  }
}

data "external" "frontend_secret_output" {
  program = ["bash", "${path.module}/files/data_source.sh"]
  depends_on = ["module.chef_server_build"]

  query = {
    ssh_user      = var.ssh_user_name
    ssh_key       = var.ssh_user_private_key
    ssh_pass      = var.ssh_user_pass
    target_ip     = var.ip
    target_script = var.frontend_script_path
  }
}
