
resource "azuread_application" "application" {
  display_name     = var.display_name
  owners           = var.owners
  sign_in_audience = var.sign_in_audience
  identifier_uris  = var.identifier_uris

  dynamic "api" {
    for_each = var.api

    content {
      known_client_applications = [] # not lazy at all
      dynamic "oauth2_permission_scope" {
        for_each = api.value.oauth2_permission_scopes
        content {
          admin_consent_description  = oauth2_permission_scope.value.admin_consent_description
          admin_consent_display_name = oauth2_permission_scope.value.admin_consent_display_name
          id                         = oauth2_permission_scope.value.id
          type                       = oauth2_permission_scope.value.type
          value                      = oauth2_permission_scope.value.value
        }
      }
    }
  }

  dynamic "required_resource_access" {
    for_each = var.required_resource_access
    content {
      resource_app_id = required_resource_access.value["resource_app_id"]

      dynamic "resource_access" {
        for_each = required_resource_access.value["resource_access"]
        content {
          id   = resource_access.value["id"]
          type = resource_access.value["type"]
        }
      }
    }
  }

  dynamic "public_client" {
    for_each = var.public_client
    content {
      redirect_uris = public_client.value["redirect_uris"]
    }
  }

  dynamic "single_page_application" {
    for_each = var.single_page_application
    content {
      redirect_uris = single_page_application.value["redirect_uris"]
    }
  }


  dynamic "app_role" {
    for_each = var.app_role
    content {
      allowed_member_types = app_role.value["allowed_member_types"]
      description          = app_role.value["description"]
      display_name         = app_role.value["display_name"]
      enabled              = app_role.value["is_enabled"]
      value                = app_role.value["value"]
      id                   = app_role.id
    }
  }

}

resource "azuread_service_principal" "service_principal" {
  alternative_names            = [] # trying to fix some stuff that terraform has found to have been modified outside of terraform
  application_id               = azuread_application.application.application_id
  app_role_assignment_required = false
  notification_email_addresses = [] # trying to fix some stuff that terraform has found to have been modified outside of terraform
  owners                       = var.owners

}


resource "azuread_application_password" "password" {
  count                 = var.create_password ? 1 : 0
  display_name          = "Terraform was here."
  application_object_id = azuread_application.application.object_id
}


resource "azurerm_role_assignment" "role_assignment" {
  for_each             = { for assignment in var.role_assignments : assignment.id => assignment }
  scope                = each.value["scope"]
  role_definition_name = each.value["role_name"]
  principal_id         = azuread_service_principal.service_principal.object_id
}


data "azurerm_key_vault" "keyvault" {
  count               = var.create_password ? 1 : 0
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_secret" "app_secret" {
  count        = var.create_password ? 1 : 0
  name         = var.display_name
  value        = azuread_application_password.password[0].value
  key_vault_id = data.azurerm_key_vault.keyvault[0].id
}

