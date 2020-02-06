################## connection #####################
variable "ips" {
  description = "A list of ip addresses where the chef server will be installed"
  type        = list
}

variable "instance_count" {
  description = "The number of instances being created"
  type        = number
}

variable "ssh_user_name" {
  description = "The ssh user name used to access the ip addresses provided" 
  type        = string
}

variable "ssh_user_pass" {
  description = "The ssh user password used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)"
  type        = string
  default     = ""
}

variable "ssh_user_private_key" {
  description = "The ssh user key used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)"
  type        = string
  default     = ""
}

variable "timeout" {
  description = "The timeout to wait for the connection to become available. Should be provided as a string like 30s or 5m. Defaults to 5 minutes."
  type        = string
  default     = "5m"
}

#################### starter pack #################

variable "starter_pack_knife_rb_path" {
  description = "Internal value for creating a knife.rb"
  type        = string
  default     = "/var/tmp/knife.rb"
}

variable "starter_pack_location" {
  description = "Internal value for creating a starter pack"
  type        = string
  default     = "/var/tmp/chef-starter-pack.tar.gz"
}

variable "tmp_path" {
  description = "A path to use for installation scripts"
  type        = string
  default     = "/var/tmp"
}

############ policyfile_module ##################
variable "cookbooks" {
  description = "the cookbooks used to deploy chef server"
  default     = {
    "chef_server_wrapper" = "github: 'srb3/chef_server_wrapper', tag: 'v0.1.46'",
    "chef-ingredient"     = "github: 'chef-cookbooks/chef-ingredient', tag: 'v3.1.1'"
  }
}

variable "runlist" {
  description = "The chef run list used to deploy chef server"
  type        = list
  default     = ["chef_server_wrapper::default"]
}

variable "policyfile_name" {
  description = "The name to give the resulting policy file"
  type        = string
  default     = "chef_server"
}

################ attribute json ##################
variable "automate_module" {
  description = "The module output of the chef automate modeule "
}

variable "channel" {
  description = "The install channel to use for the chef server"
  type        = string
  default     = "stable"
}

variable "install_version" {
  description = "The version of chef server to install"
  type        = string
  default     = "13.0.17"
}

variable "accept_license" {
  description = "Shall we accept the chef product license"
  type        = bool
  default     = true
}

variable "data_collector_url" {
  description = "The url to a data collector (automate) end point"
  type        = list(string)
  default     = []
}

variable "data_collector_token" {
  description = "The token used to access the data collector end point"
  type        = list(string)
  default     = []
}

variable "config" {
  description = "Extra config to be passed to a chef server"
  type        = string
  default     = ""
}

variable "config_block" {
  description = "Extra config passed in the form of a map (used for chef ha cluster)"
  type        = map
  default     = {}
}

variable "addons" {
  description = "Any addons to be installed should be included in this map"
  type        = map
  default     = {}
}

variable "supermarket_url" {
  description = "Use this to configure the chef server to talk to a supermarket instance"
  type        = list(string)
  default     = []
}

variable "fqdns" {
  description = "A list of fully qualified host names to apply to each chef server being created"
  type        = list(string)
  default     = []
}

variable "certs" {
  description = "A list of ssl certificates to apply to each chef server"
  type        = list(string)
  default     = []
}

variable "cert_keys" {
  description = "A list of ssl private keys to apply to each chef server"
  type        = list(string)
  default     = []
}

variable "users" {
  description = "A map of users to be added to the chef server and their details"
  type        = map(object({ serveradmin=bool, first_name=string, last_name=string, email=string, password=string }))
  default     = {}
}

variable "orgs" {
  description = "A map of organisations to be added to the chef server"
  type        = map(object({ admins=list(string), org_full_name=string }))
  default     = {}
}

variable "data_source_script_path" {
  description = "The location data source script used to gather chef server details"
  type        = string
  default     = "/var/tmp/chef_server_details.sh"
}

variable "frontend_script_path" {
  description = "The location data source script used to gather frontend secrets from a bootstrapped frontend"
  type        = string
  default     = "/var/tmp/frontend_secrets.sh"
}

variable "frontend_secrets" {
  description = "A list of secrets to apply to each frontend; for use in a HA cluster"
  type        = list
  default     = []
}

variable "force_run" {
  description = "Set to anything other than default to force a rerun of provisioning on all servers"
  type        = string
  default     = "default"
}
