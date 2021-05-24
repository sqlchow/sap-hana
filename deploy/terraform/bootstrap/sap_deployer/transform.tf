// Input variables from json
locals {
  json_environment        = try(var.infrastructure.environment, "")
  json_location           = try(var.infrastructure.region, "")
  json_codename           = try(var.infrastructure.codename, "")
  json_deployer_rg_name   = try(var.infrastructure.resource_group.name, "")
  json_deployer_rg_arm_id = try(var.infrastructure.resource_group.arm_id, "")

  json_vnet_mgmt_name              = try(var.infrastructure.vnets.management.name, "")
  json_vnet_mgmt_arm_id            = try(var.infrastructure.vnets.management.arm_id, "")
  json_deployer_vnet_address_space = try(var.infrastructure.vnets.management.address_space, "")

  json_sub_mgmt_name            = try(var.infrastructure.vnets.management.subnet_mgmt.name, "")
  json_sub_mgmt_arm_id          = try(var.infrastructure.vnets.management.subnet_mgmt.arm_id, "")
  json_sub_mgmt_prefix          = try(var.infrastructure.vnets.management.subnet_mgmt.prefix, "")
  json_sub_mgmt_nsg_name        = try(var.infrastructure.vnets.management.nsg_mgmt.name, "")
  json_sub_mgmt_nsg_arm_id      = try(var.infrastructure.vnets.management.nsg_mgmt.arm_id, "")
  json_sub_mgmt_nsg_allowed_ips = try(var.infrastructure.vnets.management.subnet_mgmt.nsg.allowed_ips, [])

  json_sub_fw_arm_id = try(var.infrastructure.vnets.management.subnet_fw.arm_id, "")
  json_sub_fw_prefix = try(var.infrastructure.vnets.management.subnet_fw.prefix, "")

  json_deployer_size                = try(var.deployers[0].size, "")
  json_deployer_disk_type           = try(var.deployers[0].disk_type, "")
  json_deployer_use_DHCP            = try(var.deployers[0].use_DHCP, null)
  json_deployer_authentication_type = try(var.deployers[0].authentication.type, "")
  json_deployer_private_ip_address  = try(var.deployers[0].private_ip_address, "")
  json_deployer_os                  = try(var.deployers[0].os, {})

  json_enable_deployer_public_ip = try(var.options.enable_deployer_public_ip, null)
  json_key_vault                 = try(var.key_vault, {})

  json_deployer_authentication = try(var.authentication, {})

  json_deployer_firewall_deployment             = try(var.firewall_deployment, null)
  json_deployer_firewall_rule_subnets           = try(var.firewall_rule_subnets, [])
  json_deployer_firewall_allowed_ipaddresses    = try(var.firewall_allowed_ipaddresses, [])
  json_deployer_assign_subscription_permissions = try(var.assign_subscription_permissions, null)
}

locals {
  infrastructure = {
    region      = local.json_location != "" ? local.json_location : var.deployer_location
    environment = local.json_environment != "" ? local.json_environment : var.deployer_environment
    codename    = local.json_codename != "" ? local.json_codename : var.deployer_codename
    resource_group = {
      name   = local.json_deployer_rg_name != "" ? local.json_deployer_rg_name : var.deployer_resourcegroup_name
      arm_id = local.json_deployer_rg_arm_id != "" ? local.json_deployer_rg_arm_id : var.deployer_resourcegroup_arm_id
    }
    vnets = {
      management = {
        name          = local.json_vnet_mgmt_name != "" ? local.json_vnet_mgmt_name : var.deployer_vnet_mgmt_name
        arm_id        = local.json_vnet_mgmt_arm_id != "" ? local.json_vnet_mgmt_arm_id : var.deployer_vnet_mgmt_arm_id
        address_space = local.json_deployer_vnet_address_space != "" ? local.json_deployer_vnet_address_space : var.deployer_vnet_address_space

        subnet_mgmt = {
          name   = local.json_sub_mgmt_name != "" ? local.json_sub_mgmt_name : var.deployer_sub_mgmt_name
          arm_id = local.json_sub_mgmt_arm_id != "" ? local.json_sub_mgmt_arm_id : var.deployer_sub_mgmt_arm_id
          prefix = local.json_sub_mgmt_prefix != "" ? local.json_sub_mgmt_prefix : var.deployer_sub_mgmt_prefix
          nsg = {
            name        = local.json_sub_mgmt_nsg_name != "" ? local.json_sub_mgmt_nsg_name : var.deployer_sub_mgmt_nsg_name
            arm_id      = local.json_sub_mgmt_nsg_arm_id != "" ? local.json_sub_mgmt_nsg_arm_id : var.deployer_sub_mgmt_nsg_arm_id
            allowed_ips = local.json_sub_mgmt_nsg_allowed_ips != [] ? local.json_sub_mgmt_nsg_allowed_ips : var.deployer_sub_mgmt_nsg_allowed_ips
          }
        }
        subnet_fw = {
          arm_id = local.json_sub_fw_arm_id != "" ? local.json_sub_fw_arm_id : var.deployer_sub_fw_arm_id
          prefix = local.json_sub_fw_prefix != "" ? local.json_sub_fw_prefix : var.deployer_sub_fw_prefix
        }
      }
    }
  }
  deployers = [
    {
      size      = local.json_deployer_size != "" ? local.json_deployer_size : var.deployer_size
      disk_type = local.json_deployer_disk_type != "" ? local.json_deployer_disk_type : var.deployer_disk_type
      use_DHCP  = local.json_deployer_use_DHCP != null ? local.json_deployer_use_DHCP : var.deployer_use_DHCP
      authentication = {
        type = local.json_deployer_authentication_type != "" ? local.json_deployer_authentication_type : var.deployer_authentication_type
      }
      os = {
        source_image_id = try(local.json_deployer_os.source_image_id, try(var.deployer_os.source_image_id, ""))
        publisher       = try(local.json_deployer_os.publisher, try(var.deployer_os.publisher, ""))
        offer           = try(local.json_deployer_os.offer, try(var.deployer_os.offer, ""))
        sku             = try(local.json_deployer_os.sku, try(var.deployer_os.sku, ""))
        version         = try(local.json_deployer_os.version, try(var.deployer_os.version, ""))
      }
      private_ip_address = local.json_deployer_private_ip_address != "" ? local.json_deployer_private_ip_address : var.deployer_private_ip_address
    }
  ]
  authentication = {
    username            = local.json_deployer_authentication.username != "" ? local.json_deployer_authentication.username : var.deployer_authentication_username
    password            = try(local.json_deployer_authentication.password, "") != "" ? local.json_deployer_authentication.password : var.deployer_authentication_password
    path_to_public_key  = local.json_deployer_authentication.path_to_public_key != "" ? local.json_deployer_authentication.path_to_public_key : var.deployer_authentication_path_to_public_key
    path_to_private_key = local.json_deployer_authentication.path_to_private_key != "" ? local.json_deployer_authentication.path_to_private_key : var.deployer_authentication_path_to_private_key

  }
  key_vault = {
    kv_user_id     = try(local.json_key_vault.kv_user_id, try(var.deployer_key_vault_kv_user_id, ""))
    kv_prvt_id     = try(local.json_key_vault.kv_prvt_id, try(var.deployer_key_vault_kv_prvt_id, ""))
    kv_sshkey_prvt = try(local.json_key_vault.kv_sshkey_prvt, try(var.deployer_key_vault_kv_sshkey_prvt, ""))
    kv_sshkey_pub  = try(local.json_key_vault.kv_sshkey_pub, try(var.deployer_key_vault_kv_sshkey_pub, ""))
    kv_username    = try(local.json_key_vault.kv_username, try(var.deployer_key_vault_kv_username, ""))
    kv_pwd         = try(local.json_key_vault.kv_pwd, try(var.deployer_key_vault_kv_pwd, ""))

  }

  options = {
    enable_deployer_public_ip = local.json_enable_deployer_public_ip != "" ? local.json_enable_deployer_public_ip : var.deployer_options_enable_deployer_public_ip
  }

  firewall_deployment = local.json_deployer_firewall_deployment != null ? local.json_deployer_firewall_deployment : var.deployer_firewall_deployment

  firewall_rule_subnets = local.json_deployer_firewall_rule_subnets != [] ? local.json_deployer_firewall_rule_subnets : var.deployer_firewall_rule_subnets

  firewall_allowed_ipaddresses = local.json_deployer_firewall_allowed_ipaddresses != [] ? local.json_deployer_firewall_allowed_ipaddresses : var.deployer_firewall_allowed_ipaddresses

  assign_subscription_permissions = local.json_deployer_assign_subscription_permissions != null ? local.json_deployer_assign_subscription_permissions : var.deployer_assign_subscription_permissions
}