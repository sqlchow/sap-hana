// retrieve public key from sap landscape's Key vault
data "azurerm_key_vault_secret" "sid_pk" {
  count        = local.enable_auth_key ? 1 : 0
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


// Generate random password if password is set as authentication type and user doesn't specify a password, and save in KV
resource "random_password" "password" {
  count = (
    local.enable_auth_password
  && try(local.hdb.authentication.password, null) == null) ? 1 : 0
  length           = 16
  special          = true
  override_special = "_%@"
}

// Store the hdb logon username in KV 
resource "azurerm_key_vault_secret" "auth_username" {
  count        = local.sid_local_credentials_exist ? 1 : 0
  name         = format("%s-hdb-auth-username", local.prefix)
  value        = local.sid_auth_username
  key_vault_id = local.sid_kv_user.id
}

// Store the hdb logon username in KV when authentication type is password
resource "azurerm_key_vault_secret" "auth_password" {
  count        = local.enable_auth_password && local.sid_local_credentials_exist ? 1 : 0
  name         = format("%s-hdb-auth-password", local.prefix)
  value        = local.sid_auth_password
  key_vault_id = local.sid_kv_user.id
}
