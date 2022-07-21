# Staff-infrastructure-alz-terraform-azuread-application

Azure Active Directory Applications are generally used to provide authentication via a service principal for a range of usages, e.g. authentication for pipelines or SSO using AzureAD

This module creates and maintains the Azure AD Application, Service principal (enterprise app in the portal) as well as optionally secrets in a **pre-existing** Azure Keyvault.

It would be relatively straight forward to add other places to store secrets, e.g. github for use in Github Actions or AWS SSM

See the [terraform resource page for azure ad apps](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) for further info.

Finally, note that his has been done on my last day of work for the MoJ so this _might_ not be as polished as it could've been.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0.7 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | 2.22.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 2.80.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 2.22.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 2.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.application](https://registry.terraform.io/providers/hashicorp/azuread/2.22.0/docs/resources/application) | resource |
| [azuread_application_password.password](https://registry.terraform.io/providers/hashicorp/azuread/2.22.0/docs/resources/application_password) | resource |
| [azuread_service_principal.service_principal](https://registry.terraform.io/providers/hashicorp/azuread/2.22.0/docs/resources/service_principal) | resource |
| [azurerm_key_vault_secret.app_secret](https://registry.terraform.io/providers/hashicorp/azurerm/2.80.0/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/2.80.0/docs/resources/role_assignment) | resource |
| [azurerm_key_vault.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/2.80.0/docs/data-sources/key_vault) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api"></a> [api](#input\_api) | n/a | <pre>list(object({<br>    oauth2_permission_scopes = list(object({<br>      admin_consent_description  = string<br>      admin_consent_display_name = string<br>      id                         = string<br>      type                       = string<br>      value                      = string<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_app_role"></a> [app\_role](#input\_app\_role) | Roles that the application might define, see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_app_role for more details.<br>  Note that the assignments field doesn't really do anything at this point in time, but the hope is that it will be used for passing into a script that will sort them out | <pre>list(object({<br>    allowed_member_types = list(string)<br>    description          = string<br>    display_name         = string<br>    enabled              = bool<br>    value                = string,<br>    id                   = string<br>    assignments          = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_create_password"></a> [create\_password](#input\_create\_password) | n/a | `bool` | `false` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | n/a | `any` | n/a | yes |
| <a name="input_identifier_uris"></a> [identifier\_uris](#input\_identifier\_uris) | A set of user-defined URI(s) that uniquely identify an application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant. | `list(string)` | `null` | no |
| <a name="input_keyvault_name"></a> [keyvault\_name](#input\_keyvault\_name) | This is the name of the key vault where the secrets will be stored | `string` | `""` | no |
| <a name="input_owners"></a> [owners](#input\_owners) | Who owns the app. Unless there is a good reason for this leave blank | `list(string)` | `null` | no |
| <a name="input_public_client"></a> [public\_client](#input\_public\_client) | This is the redirect uri field in the portal. We use this to allow cross tenant access. So far the only use is to allow pipelines the access to shared images for the Palo Alto Firewalls | <pre>list(object({<br>    redirect_uris = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_required_resource_access"></a> [required\_resource\_access](#input\_required\_resource\_access) | This is the API Permissions field in the portal, essentially, I don't know look it up on google or something. | <pre>list(object({<br>    resource_app_id = string<br>    resource_access = list(object({<br>      id   = string<br>      type = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where KV and Storage Account will be created | `string` | `""` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Assign azure RBAC Roles to the sp. | <pre>list(object({<br>    id        = string<br>    role_name = string<br>    scope     = string<br>  }))</pre> | `[]` | no |
| <a name="input_sign_in_audience"></a> [sign\_in\_audience](#input\_sign\_in\_audience) | The account types that are supported for teh application. Restricting to business accounts | `string` | `"AzureADMyOrg"` | no |
| <a name="input_single_page_application"></a> [single\_page\_application](#input\_single\_page\_application) | This is the redirect uri field in the portal. | <pre>list(object({<br>    redirect_uris = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | This is the name of the storage account where the secret references will be stored | `string` | `""` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | n/a |
<!-- END_TF_DOCS -->


## Calling Code

This is a suggestion of what the calling code might look like

```hcl
locals {
  applications = defaults(var.applications, {
    api                      = {}
    app_role                 = {}
    create_password          = false
    identifier_uris          = ""
    owners                   = ""
    public_client            = {}
    required_resource_access = {}
    role_assignments         = {}
    sign_in_audience         = "AzureADMyOrg"
    single_page_application  = {}
  })
}

module "application" {
  source                   = 
  for_each                 = local.applications
  app_role                 = each.value.app_role
  api                      = each.value.api
  create_password          = each.value.create_password
  display_name             = each.key
  identifier_uris          = each.value.identifier_uris
  keyvault_name            = var.keyvault_name
  owners                   = each.value.owners
  public_client            = each.value.public_client
  single_page_application  = each.value.single_page_application
  resource_group_name      = var.resource_group_name
  required_resource_access = each.value.required_resource_access
  role_assignments         = each.value.role_assignments
  sign_in_audience         = each.value.sign_in_audience
  storage_account_name     = var.storage_account_name
  tenant_id                = var.tenant_id
}


}
```
where applications is variable like this

```hcl
variable "applications" {
  description = "A map of applications where the key is the app name"
  type = map(object({

    api = optional(list(object({
      oauth2_permission_scopes = list(object({
        admin_consent_description  = string
        admin_consent_display_name = string
        id                         = string
        type                       = string
        value                      = string
      }))

    })))


    app_role = optional(list(object({
      allowed_member_types = list(string)
      description          = string
      display_name         = string
      enabled              = bool
      value                = string,
      id                   = string
      assignments          = list(string)
    })))

    create_password = optional(bool)

    identifier_uris = optional(list(string))

    owners = optional(list(string))

    public_client = optional(list(object({
      redirect_uris = list(string)
    })))

    required_resource_access = optional(list(object({
      resource_app_id = string
      resource_access = list(object({
        id   = string
        type = string
      }))
    })))

    role_assignments = optional(list(object({
      id        = string
      role_name = string
      scope     = string
    })))

    sign_in_audience = optional(string)

    single_page_application = optional(list(object({
      redirect_uris = list(string)
    })))


  }))

  default = {}
}
```

This would allow to have all the configuration in a single file, though it might be preferable to have several configuration files, e.g. one per team, that are loaded by terraform.

## Cross Tenant Application Usage.

It is possible to use an azure ad application across Azure AD tenants but the configuration is not obvious, see [below](#instructions) for details.

If this is configured properly, see example below, then it will be possible to install this application as an enterprise application (service principal) into a different tenant.  Unfortunately, this is a manual process.

```hcl
  "MyAPP" = {
    app_role = []
    public_client = [
      {
        redirect_uris = ["https://www.microsoft.com/"]
      }
    ]
    owners = []
    required_resource_access = [
      {
        resource_app_id = "00000003-0000-0000-c000-000000000000"
        resource_access = [{
          id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
          type = "Scope"
        }]
      }
    ]
    role_assignments = []
    sign_in_audience = "AzureADMultipleOrgs"
  },
```

### Instructions

Let's say we wanted to grant an application called MyAPP hosted in tenant production access to the development tenant

1. We would need to craft a url like this

```
https://login.microsoftonline.com/<Tenant ID>/oauth2/authorize?client_id=<ClientId>&response_type=code&redirect_uri=https%3A%2F%2Fwww.microsoft.com%2F
```

where Tenant ID is the tenant where you want the MyAPP app to have access to (development tenant in this case) and ClienID is the MyAPP's ClientID.

2. Navigate to said url and click Accept on the MS Prompt  (I'm not 100% what permissions are required on both tenants, Global Admin? on the receiving tenant, Some sort of reader on the tenant where the app resides)

![prompt](/assets/shared%20images.png)

3. It will now be possible to assign an RBAC role to MyAPP App in the development environment as this has now been installed as a third party app and will show on the Enterprise applications, which can be found in the Azure Active Directory section of the Azure Portal.


