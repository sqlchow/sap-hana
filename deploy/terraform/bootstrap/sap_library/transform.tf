
locals {
  infrastructure = {
    environment = try(var.library_environment, var.infrastructure.environment)
    region      = try(var.library_location, var.infrastructure.region)
    resource_group = {
      name   = try(var.library_resourcegroup_name, var.infrastructure.resource_group.name)
      arm_id = try(var.library_resourcegroup_arm_id, var.infrastructure.resource_group.arm_id)
    }
  }
  deployer = {
    environment = try(var.deployer_environment, var.deployer.environment)
    region      = try(var.deployer_location, var.deployer.region)
    vnet        = try(var.deployer_vnet, var.deployer.vnet)
    use         = try(var.deployer_use, var.deployer.use)

  }
  key_vault = {
    kv_user_id = try(var.library_key_vault_kv_user_id, var.key_vault.kv_user_id)
    kv_prvt_id = try(var.library_key_vault_kv_prvt_id, var.key_vault.kv_prvt_id)
    kv_prvt_id = try(var.library_key_vault_kv_spn_id, var.key_vault.kv_spn_id)
  }
  storage_account_sapbits = {
    arm_id                   = try(var.library_sapbits_arm_id, var.storage_account_sapbits.arm_id)
    account_tier             = try(var.library_sapbits_account_tier, var.storage_account_sapbits.account_tier)
    account_replication_type = try(var.library_sapbits_account_replication_type, var.storage_account_sapbits.account_replication_type)
    account_kind             = try(var.library_sapbits_account_kind, var.storage_account_sapbits.account_kind)
    file_share = {
      enable_deployment = try(var.library_sapbits_file_share_enable_deployment, var.storage_account_sapbits.file_share.enable_deployment)
      is_existing       = try(var.library_sapbits_file_share_is_existing, var.storage_account_sapbits.file_share.is_existing)
      name              = try(var.library_sapbits_file_share_name, var.storage_account_sapbits.file_share.name)
    }
    sapbits_blob_container = {
      enable_deployment = try(var.library_sapbits_blob_container_enable_deployment, var.storage_account_sapbits.sapbits_blob_container.enable_deployment)
      is_existing       = try(var.library_sapbits_blob_container_is_existing, var.storage_account_sapbits.sapbits_blob_container.is_existing)
      name              = try(var.library_sapbits_blob_container_name, var.storage_account_sapbits.sapbits_blob_container.name)
    }
  }
  storage_account_tfstate = {
    arm_id                   = try(var.library_tfstate_arm_id, var.storage_account_tfstate.arm_id)
    account_tier             = try(var.library_tfstate_account_tier, var.storage_account_tfstate.account_tier)
    account_replication_type = try(var.library_tfstate_account_replication_type, var.storage_account_tfstate.account_replication_type)
    account_kind             = try(var.library_tfstate_account_kind, var.storage_account_tfstate.account_kind)
    tfstate_blob_container = {
      is_existing = try(var.library_tfstate_blob_container_is_existing, var.storage_account_tfstate.tfstate_blob_container.is_existing)
      name        = try(var.library_tfstate_blob_container_name, var.storage_account_tfstate.tfstate_blob_container.name)
    }
    ansible_blob_container = {
      is_existing = try(var.library_ansible_blob_container_is_existing, var.storage_account_tfstate.ansible_blob_container.is_existing)
      name        = try(var.library_ansible_blob_container_name, var.storage_account_tfstate.ansible_blob_container.name)
    }
  }

}