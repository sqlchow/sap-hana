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

/*
 To force dependency between kv access policy and secrets. Expected behavior:
 https://github.com/terraform-providers/terraform-provider-azurerm/issues/4971
*/

// Store the app logon username in KV when authentication type is password
resource "azurerm_key_vault_secret" "app_auth_username" {
  count        = local.enable_auth_password && local.use_landscape_credentials ? 1 : 0
  name         = format("%s-%s-app-auth-username", local.prefix, local.sid)
  value        = local.sid_auth_username
  key_vault_id = local.sid_kv_user.id
}

// Store the app logon username in KV when authentication type is password
resource "azurerm_key_vault_secret" "app_auth_password" {
  count        = local.enable_auth_password  && local.use_landscape_credentials? 1 : 0
  name         = format("%s-%s-app-auth-password", local.prefix, local.sid)
  value        = local.sid_auth_password
  key_vault_id = local.sid_kv_user.id
}
