/*
  Description:
  Set up key vault for sap system
*/

// retrieve public key from sap landscape's Key vault
data "azurerm_key_vault_secret" "sid_pk" {
  count        = local.enable_anchor_auth_key ? 1 : 0
  name         = local.secret_sid_pk_name
  key_vault_id = local.kv_landscape_id
}

data "azurerm_key_vault_secret" "sid_username" {
  count        = local.enable_auth_password ? 1 : 0
  name         = local.sid_username_secret_name
  key_vault_id = local.kv_landscape_id
}

data "azurerm_key_vault_secret" "sid_password" {
  count        = local.enable_auth_password ? 1 : 0
  name         = local.sid_password_secret_name
  key_vault_id = local.kv_landscape_id
}


// Create private KV with access policy
resource "azurerm_key_vault" "sid_kv_prvt" {
  count                      = local.enable_sid_deployment ? 1 : 0
  name                       = local.sid_keyvault_names.private_access
  location                   = local.region
  resource_group_name        = local.rg_exists ? data.azurerm_resource_group.resource_group[0].name : azurerm_resource_group.resource_group[0].name
  tenant_id                  = local.service_principal.tenant_id
  soft_delete_enabled        = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  sku_name                   = "standard"

  access_policy {
    tenant_id = local.service_principal.tenant_id
    object_id = local.service_principal.object_id

    secret_permissions = [
      "get",
    ]
  }

}

// Create user KV with access policy
resource "azurerm_key_vault" "sid_kv_user" {
  count                      = local.enable_sid_deployment ? 1 : 0
  name                       = local.sid_keyvault_names.user_access
  location                   = local.region
  resource_group_name        = local.rg_exists ? data.azurerm_resource_group.resource_group[0].name : azurerm_resource_group.resource_group[0].name
  tenant_id                  = local.service_principal.tenant_id
  soft_delete_enabled        = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  sku_name                   = "standard"

  access_policy {
    tenant_id = local.service_principal.tenant_id
    object_id = local.service_principal.object_id

    secret_permissions = [
      "delete",
      "get",
      "list",
      "set",
    ]

  }
}

/* Comment out code with users.object_id for the time being
resource "azurerm_key_vault_access_policy" "sid_kv_user_portal" {
  count        = local.enable_sid_deployment ? length(local.kv_users) : 0
  key_vault_id = azurerm_key_vault.sid_kv_user[0].id
  tenant_id    = data.azurerm_client_config.deployer.tenant_id
  object_id    = local.kv_users[count.index]
  secret_permissions = [
    "delete",
    "get",
    "list",
    "set",
  ]
}
*/
// random bytes to product
resource "random_id" "sapsystem" {
  byte_length = 4
}

resource "random_password" "password" {
  count = ((
    local.enable_app_auth_password || local.enable_db_auth_password
    ) && ((
    try(var.application.authentication.password, null) == null)) || (try(var.databases[0].authentication.password, null) == null)
  ) ? 1 : 0

  length      = 32
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}

// Store the hdb logon username in KV when authentication type is password
resource "azurerm_key_vault_secret" "auth_username" {
  count        = local.enable_auth_password && local.use_landscape_credentials ? 1 : 0
  name         = format("%s-username", local.prefix)
  value        = local.sid_auth_username
  key_vault_id = local.sid_kv_user.id
}

// Store the hdb logon username in KV when authentication type is password
resource "azurerm_key_vault_secret" "auth_password" {
  count        = local.enable_auth_password && local.use_landscape_credentials ? 1 : 0
  name         = format("%s-password", local.prefix)
  value        = local.sid_auth_password
  key_vault_id = local.sid_kv_user.id
}

