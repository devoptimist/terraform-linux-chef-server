locals {
  chef_server_users = {
    "jdoe" = {
      "serveradmin" = true,
      "first_name"  = "Jane",
      "last_name"   = "Doe",
      "email"       = "jdoe@company.com",
      "password"    = "s0meP@55!"
    }
  }

  chef_server_orgs = {
    "acmecorp" = {
      "admins"        = ["jdoe"],
      "org_full_name" = "My Company"
    }
  }
}

module "aws_chef_server" {
  source                           = "../../../examples/aws"
  aws_region                       = var.aws_region
  aws_profile                      = var.aws_profile
  aws_creds_file                   = var.aws_creds_file
  aws_key_name                     = var.aws_key_name
  chef_server_ingress_cidrs        = var.chef_server_ingress_cidrs
  chef_server_ssh_user_private_key = var.chef_server_ssh_user_private_key
  chef_server_users                = local.chef_server_users
  chef_server_orgs                 = local.chef_server_orgs
  tags                             = var.tags
}
