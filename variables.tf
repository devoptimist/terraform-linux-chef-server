################## connection #####################
variable "ips" {
  type    = list
  default = []
}

variable "instance_count" {
  default = 0
}

variable "ssh_user_name" {
  type    = "string"
}

variable "ssh_user_pass" {
  type    = "string"
  default = ""
}

variable "ssh_user_private_key" {
  type    = "string"
  default = ""
}
#################### starter pack #################

variable "starter_pack_knife_rb_path" {
  type    = string
  default = "/var/tmp/knife.rb"
}

variable "starter_pack_location" {
  type    = string
  default = "/var/tmp/chef-starter-pack.tar.gz"
}

variable "starter_pack_dest" {
  type    = string
  default = "/var/tmp/chef-starter-pack.tar.gz"
}

variable "tmp_path" {
  type    = string
  default = "/var/tmp"
}

############ policyfile_module ##################
variable "cookbooks" {
  default = {
    "chef_server_wrapper" = "github: 'devoptimist/chef_server_wrapper', tag: 'v0.1.45'",
    "chef-ingredient" = "github: 'chef-cookbooks/chef-ingredient', tag: 'v3.1.1'"
  }
}

variable "runlist" {
  type    = list
  default = ["chef_server_wrapper::default"]
}

################ attribute json ##################
variable "channel" {
  type    = string
  default = "stable"
}

variable "install_version" {
  type    = string
  default = "13.0.17"
}

variable "accept_license" {
  default = true
}

variable "data_collector_url" {
  type    = list(string)
  default = []
}

variable "data_collector_token" {
  type    = list(string)
  default = []
}

variable "config" {
  type    = string
  default = ""
}

variable "config_block" {
  type    = map
  default = {}
}

variable "addons" {
  type    = map
  default = {}
}

variable "supermarket_url" {
  type    = list(string)
  default = []
}

variable "fqdns" {
  type    = list(string)
  default = []
}

variable "certs" {
  type    = list(string)
  default = []
}

variable "cert_keys" {
  type    = list(string)
  default = []
}

variable "users" {
  type    = map(object({ serveradmin=bool, first_name=string, last_name=string, email=string, password=string }))
  default = {}
}

variable "orgs" {
  type    = map(object({ admins=list(string), org_full_name=string }))
  default = {}
}

variable "data_source_script_path" {
  type    = string
  default = "/var/tmp/chef_server_details.sh"
}

variable "frontend_script_path" {
  type    = string
  default = "/var/tmp/frontend_secrets.sh"
}

variable "frontend_secrets" {
  type    = list
  default = []
}

variable "force_run" {
  type    = string
  default = "default"
}
