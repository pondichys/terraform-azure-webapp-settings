provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  # version = "1.24.0"

  features {}
}

data "azurerm_resource_group" "cloudrg" {
  for_each = local.webapp

  name     = each.value["asprg"]
}

data "azurerm_app_service_plan" "asp" {
  for_each = local.webapp

  name     = each.value["asp"]
  resource_group_name = data.azurerm_resource_group.cloudrg[each.key].name
}

# resource "azurerm_resource_group" "webrg" {
#   for_each = local.webapp

#   name     = "rg-${each.value["webapp_name"]}-web"
#   location = "West Europe"

#   tags = local.common_tags
# }

# resource "azurerm_application_insights" "webai" {
#   for_each = var.webapp

#   name                = "ai-${each.value["webapp_name"]}-web"
#   location            = azurerm_resource_group.webrg[each.key].location
#   resource_group_name = azurerm_resource_group.webrg[each.key].name
#   application_type    = "web"

#   tags = local.common_tags
# }

resource "azurerm_app_service" "webapp" {
  for_each = local.webapp

  name                = each.value["webapp_name"]
  location            = data.azurerm_resource_group.cloudrg[each.key].location
  resource_group_name = data.azurerm_resource_group.cloudrg[each.key].name
  app_service_plan_id = data.azurerm_app_service_plan.asp[each.key].id

  site_config {
    linux_fx_version = each.value["kind"] == "Linux" ? each.value["technology"] : null
    ftps_state = "FtpsOnly"
  }

  app_settings = merge({"TEST KEY" = "TEST VALUE"},try(each.value["app_settings"],{}) )

  dynamic "connection_string" {
    for_each = [for v in [each.value] : v.connectionstring if lookup(v, "connectionstring", null) != null]   
    
    content {
      name  = each.value.connectionstring.name
      type  = each.value.connectionstring.type
      value = each.value.connectionstring.value
    }
  }

  tags = local.common_tags
}

# resource "azurerm_app_service_custom_hostname_binding" "customhostname" {
#   for_each = {for k,v in local.webapp : k => v.customhostname if lookup(v, "customhostname", null ) != null}

#   hostname            = each.value
#   app_service_name    = azurerm_app_service.webapp[each.key].name
#   resource_group_name = azurerm_resource_group.webrg[each.key].name
# }