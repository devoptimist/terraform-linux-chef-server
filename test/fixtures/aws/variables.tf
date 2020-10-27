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
