/*

This block describes the variable for the infrastructure block in the json file

*/

variable "deployer_environment" {
  type        = string
  description = "This is the environment name of the deployer"
  default     = ""
}

variable "deployer_codename" {
  type    = string
  default = ""
}

variable "deployer_location" {
  type    = string
  default = ""
}

variable "deployer_resourcegroup_name" {
  default = ""
}

variable "deployer_resourcegroup_arm_id" {
  default = ""
}

/*

This block describes the variables for the VNet block in the json file

*/

variable "deployer_vnet_mgmt_name" {
  default = ""
}

variable "deployer_vnet_mgmt_arm_id" {
  default = ""
}

variable "deployer_vnet_address_space" {
  default = ""
}

variable "deployer_sub_mgmt_name" {
  default = ""
}

variable "deployer_sub_mgmt_arm_id" {
  default = ""
}

variable "deployer_subnet_prefix" {
  default = ""
}

variable "sub_mgmt_nsg_name" {
  default = ""
}

variable "sub_mgmt_nsg_arm_id" {
  default = ""
}

variable "sub_mgmt_nsg_allowed_ips" {
  default = []
}

/*

This block describes the variables for the deployes section block in the json file

*/

variable "deployer_size" {
  default = "Standard_D4ds_v4"
}

variable "deployer_disk_type" {
  default = "Premium_LRS"
}

variable "deployer_use_DHCP" {
  default = false
}

/*
This block describes the variables for the deployer OS section block in the json file
*/

variable "deployer_os" {
  default = {
    "source_image_id" = ""
    "publisher"       = "Canonical"
    "offer"           = "UbuntuServer"
    "sku"             = "18.04-LTS"
    "version"         = "latest"
  }
}

variable "deployer_private_ip_address" {
  default = []
}

/*
This block describes the variables for the authentication section block in the json file
*/

variable "deployer_authentication_type" {
  default = "key"
}

variable "deployer_authentication_username" {
  default = "azureadm"
}

variable "deployer_authentication_password" {
}

variable "deployer_authentication_path_to_public_key" {
}

variable "deployer_authentication_path_to_private_key" {
}

/*
This block describes the variables for the key_vault section block in the json file
*/


variable "deployer_key_vault_kv_user_id" {
}

variable "deployer_key_vault_kv_prvt_id" {
}

variable "deployer_key_vault_kv_sshkey_prvt" {
}

variable "deployer_key_vault_kv_sshkey_pub" {
}

variable "deployer_key_vault_kv_username" {
}

variable "deployer_key_vault_kv_pwd" {
}

/*
This block describes the variables for the options section block in the json file
*/

variable "deployer_options_enable_deployer_public_ip" {
}


variable "deployer_firewall_deployment" {
  default = false
}

variable "deployer_firewall_rule_subnets" {
}

variable "firewall_allowed_ipaddresses" {
}

variable "deployer_assign_subscription_permissions" {
  default = true
}