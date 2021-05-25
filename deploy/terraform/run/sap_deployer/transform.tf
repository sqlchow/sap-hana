
locals {
  infrastructure = {
    environment = try(var.deployer_environment, var.infrastructure.environment)
    region      = try(var.deployer_location, var.infrastructure.region)
    codename    = try(var.deployer_codename, var.infrastructure.codename)
    resource_group = {
      name   = try(var.deployer_resourcegroup_name, var.infrastructure.resource_group.name)
      arm_id = try(var.deployer_resourcegroup_arm_id, var.infrastructure.resource_group.arm_id)
    }
    vnets = {
      management = {
        name          = try(var.deployer_vnet_mgmt_name, var.infrastructure.vnets.management.name)
        arm_id        = try(var.deployer_vnet_mgmt_arm_id, var.infrastructure.vnets.management.arm_id)
        address_space = try(var.deployer_vnet_address_space, var.infrastructure.vnets.management.address_space)

        subnet_mgmt = {
          name   = try(var.deployer_sub_mgmt_name, var.infrastructure.vnets.management.subnet_mgmt.name)
          arm_id = try(var.deployer_sub_mgmt_arm_id, var.infrastructure.vnets.management.subnet_mgmt.arm_id)
          prefix = try(var.deployer_sub_mgmt_prefix, var.infrastructure.vnets.management.subnet_mgmt.prefix)
          nsg = {
            name        = try(var.deployer_sub_mgmt_nsg_name, var.infrastructure.vnets.management.nsg_mgmt.name)
            arm_id      = try(var.deployer_sub_mgmt_nsg_arm_id, var.infrastructure.vnets.management.nsg_mgmt.arm_id)
            allowed_ips = try(var.deployer_sub_mgmt_nsg_allowed_ips, var.deployer_sub_mgmt_nsg_arm_id)
          }
        }
        subnet_fw = {
          arm_id = try(var.deployer_sub_fw_arm_id, var.infrastructure.vnets.management.subnet_fw.arm_id)
          prefix = try(var.deployer_sub_fw_prefix, var.infrastructure.vnets.management.subnet_fw.prefix)
        }
      }
    }
  }
  deployers = [
    {
      size      = try(var.deployer_size, var.deployers[0].size)
      disk_type = try(var.deployer_disk_type, var.deployers[0].disk_type)
      use_DHCP  = try(var.deployer_use_DHCP, var.deployers[0].use_DHCP)
      authentication = {
        type = try(var.deployer_authentication_type, var.deployers[0].authentication.type)
      }
      os = {
        source_image_id = try(var.deployer_os.source_image_id, var.deployers[0].os.source_image_id)
        publisher       = try(var.deployer_os.publisher, var.deployers[0].os.publisher)
        offer           = try(var.deployer_os.offer, var.deployers[0].os.offer)
        sku             = try(var.deployer_os.sku, var.deployers[0].os.sku)
        version         = try(var.deployer_os.version, var.deployer_os.sku)
      }
      private_ip_address = try(var.deployer_private_ip_address, var.deployer_os.sku)
    }
  ]
  authentication = {
    username            = try(var.deployer_authentication_username, var.authentication.username)
    password            = try(var.deployer_authentication_password, var.authentication.password)
    path_to_public_key  = try(var.deployer_authentication_path_to_public_key, var.authentication.path_to_public_key)
    path_to_private_key = try(var.deployer_authentication_path_to_private_key, var.authentication.path_to_private_key)

  }
  key_vault = {
    kv_user_id     = try(var.deployer_key_vault_kv_user_id, var.key_vault.kv_user_id)
    kv_prvt_id     = try(var.deployer_key_vault_kv_prvt_id, var.key_vault.kv_prvt_id)
    kv_sshkey_prvt = try(var.deployer_key_vault_kv_sshkey_prvt, var.key_vault.kv_sshkey_prvt)
    kv_sshkey_pub  = try(var.deployer_key_vault_kv_sshkey_pub, var.key_vault.kv_sshkey_pub, )
    kv_username    = try(var.deployer_key_vault_kv_username, var.key_vault.kv_username, )
    kv_pwd         = try(var.deployer_key_vault_kv_pwd, var.key_vault.kv_pwd)

  }

  options = {
    enable_deployer_public_ip = try(var.deployer_options_enable_deployer_public_ip, var.options.enable_deployer_public_ip)
  }

  firewall_deployment          = try(var.deployer_firewall_deployment, var.firewall_deployment)
  firewall_rule_subnets        = try(var.deployer_firewall_rule_subnets, var.firewall_rule_subnets)
  firewall_allowed_ipaddresses = try(var.deployer_firewall_allowed_ipaddresses, var.firewall_allowed_ipaddresses)

  assign_subscription_permissions = try(var.deployer_assign_subscription_permissions, var.assign_subscription_permissions)
}