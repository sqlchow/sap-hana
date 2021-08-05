// User defined identity for all Deployer, assign contributor to the current subscription
resource "azurerm_user_assigned_identity" "deployer" {
  resource_group_name = local.rg_exists ? data.azurerm_resource_group.deployer[0].name : azurerm_resource_group.deployer[0].name
  location            = local.rg_exists ? data.azurerm_resource_group.deployer[0].location : azurerm_resource_group.deployer[0].location
  name                = format("%s%s", local.prefix, local.resource_suffixes.msi)
}

# // Add role to be able to deploy resources
resource "azurerm_role_assignment" "sub_contributor" {
  count                = var.assign_subscription_permissions  ? 1 : 0
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.deployer.principal_id
}

