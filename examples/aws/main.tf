variable "aws_creds_file" {
  description = "The path to an aws credentials file"
  type        = string
}

variable "aws_profile" {
  description = "The name of an aws profile to use"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "The aws region to use"
  type        = string
  default     = "eu-west-1"
}

variable "aws_key_name" {
  description = "The name of an aws key pair to use for chef automate"
  type        = string
}

variable "tags" {
  description = "A set of tags to assign to the instances created by this module"
  type        = map(string)
  default     = {}
}

variable "chef_server_ingress_cidrs" {
  description = "A list of CIDR's to use for allowing access to the chef_server vm"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "chef_server_ssh_user_private_key" {
  description = "The ssh private key used to access the chef_server proxy"
  type        = string
}

variable "chef_server_users" {
  description = "A map of chef users to create on the system"
  type        = map(object({ serveradmin = bool, first_name = string, last_name = string, email = string, password = string }))
  default     = {}
}

variable "chef_server_orgs" {
  description = "A map of organisations to be added to the chef server"
  type        = map(object({ admins = list(string), org_full_name = string }))
  default     = {}
}

provider "aws" {
  shared_credentials_file = var.aws_creds_file
  profile                 = var.aws_profile
  region                  = var.aws_region
}

data "aws_availability_zones" "available" {}

module "ami" {
  source  = "srb3/ami/aws"
  version = "0.13.0"
  os_name = "centos-7"
}

resource "random_id" "hash" {
  byte_length = 4
}

locals {
  public_subnets = ["10.0.1.0/24"]
  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1]
  ]
  chef_server_ingress_rules = ["ssh-tcp", "http-80-tcp", "https-443-tcp", "consul-webui-tcp"]
  chef_server_egress_rules  = ["all-all"]
  chef_server_egress_cidrs  = ["0.0.0.0/0"]
  chef_server_instance_type = "t3.large"
  chef_server_rbd           = [{ volume_type = "gp2", volume_size = "40" }]

  sg_data = {
    "chef" = {
      "ingress_rules" = local.chef_server_ingress_rules,
      "ingress_cidr"  = var.chef_server_ingress_cidrs,
      "egress_rules"  = local.chef_server_egress_rules,
      "egress_cidr"   = local.chef_server_egress_cidrs,
      "description"   = "chef security group"
      "vpc_id"        = module.vpc.vpc_id
    }
  }

  vm_data = {
    "chef" = {
      "ami"                = module.ami.id,
      "instance_type"      = local.chef_server_instance_type,
      "key_name"           = var.aws_key_name,
      "security_group_ids" = [module.security_group["chef"].id],
      "subnet_ids"         = module.vpc.public_subnets,
      "root_block_device"  = local.chef_server_rbd,
      "public_ip_address"  = true
    }
  }

  chef_server_config = <<-EOF
  rabbitmq['queue_length_monitor_enabled'] = false
EOF

  chef_server_addons = {
    "manage" = {
      "config"  = "",
      "channel" = "stable",
      "version" = "2.5.16"
    }
  }

  chef_server_install_version = "13.0.17"
}

module "vpc" {
  source         = "srb3/vpc/aws"
  version        = "0.13.0"
  name           = "Chef Server VPC"
  cidr           = "10.0.0.0/16"
  azs            = local.azs
  public_subnets = local.public_subnets
  tags           = var.tags
}

module "security_group" {
  source              = "srb3/security-group/aws"
  version             = "0.13.1"
  for_each            = local.sg_data
  name                = each.key
  description         = each.value["description"]
  vpc_id              = each.value["vpc_id"]
  ingress_rules       = each.value["ingress_rules"]
  ingress_cidr_blocks = each.value["ingress_cidr"]
  egress_rules        = each.value["egress_rules"]
  egress_cidr_blocks  = each.value["egress_cidr"]
  tags                = var.tags
}

module "instance" {
  source                      = "srb3/vm/aws"
  version                     = "0.13.1"
  for_each                    = local.vm_data
  name                        = each.key
  ami                         = each.value["ami"]
  instance_type               = each.value["instance_type"]
  key_name                    = each.value["key_name"]
  security_group_ids          = each.value["security_group_ids"]
  subnet_ids                  = each.value["subnet_ids"]
  root_block_device           = each.value["root_block_device"]
  associate_public_ip_address = each.value["public_ip_address"]
  tags                        = var.tags
}

module "chef_server" {
  source               = "../../"
  ip                   = length(module.instance["chef"].public_ip) > 0 ? module.instance["chef"].public_ip[0] : ""
  ssh_user_name        = module.ami.user
  ssh_user_private_key = var.chef_server_ssh_user_private_key
  addons               = local.chef_server_addons
  users                = var.chef_server_users
  orgs                 = var.chef_server_orgs
  config               = local.chef_server_config
  install_version      = local.chef_server_install_version
  consul_log_level     = "debug"
}
