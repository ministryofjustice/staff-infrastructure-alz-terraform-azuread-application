
variable "api" {
  type = list(object({
    oauth2_permission_scopes = list(object({
      admin_consent_description  = string
      admin_consent_display_name = string
      id                         = string
      type                       = string
      value                      = string
    }))
  }))

}
variable "app_role" {
  description = <<EOT
  Roles that the application might define, see https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_app_role for more details.
  Note that the assignments field doesn't really do anything at this point in time, but the hope is that it will be used for passing into a script that will sort them out
  EOT
  type = list(object({
    allowed_member_types = list(string)
    description          = string
    display_name         = string
    enabled              = bool
    value                = string,
    id                   = string
    assignments          = list(string)
  }))

  default = []

}

variable "create_password" {
  type = bool
  default = false
  
}

variable "display_name" {}

variable "identifier_uris" {
  description = "A set of user-defined URI(s) that uniquely identify an application within its Azure AD tenant, or within a verified custom domain if the application is multi-tenant."
  type        = list(string)
  default     = null
}

variable "keyvault_name" {
  type = string
  description = "This is the name of the key vault where the secrets will be stored"
  default = ""
}

variable "owners" {
  description = "Who owns the app. Unless there is a good reason for this leave blank"
  type        = list(string)
  default     = null
}


variable "public_client" {
  type = list(object({
    redirect_uris = list(string)
  }))
  description = "This is the redirect uri field in the portal. We use this to allow cross tenant access. So far the only use is to allow pipelines the access to shared images for the Palo Alto Firewalls"
}

variable "required_resource_access" {
  description = "This is the API Permissions field in the portal, essentially, I don't know look it up on google or something."
  type = list(object({
    resource_app_id = string
    resource_access = list(object({
      id   = string
      type = string
    }))
  }))

  default = []

}

variable "role_assignments" {
  description = "Assign azure RBAC Roles to the sp."
  type = list(object({
    id        = string
    role_name = string
    scope     = string
  }))

  default = []
}

variable "resource_group_name" {
  description = "Name of the resource group where KV and Storage Account will be created"
  type = string
  default = ""
  
}

variable "sign_in_audience" {
  type        = string
  default     = "AzureADMyOrg"
  description = "The account types that are supported for teh application. Restricting to business accounts"
  validation {
    condition     = can(regex("^(AzureADMyOrg|AzureADMultipleOrgs)$", var.sign_in_audience))
    error_message = "Allowed values are: AzureADMyOrg or AzureADMultipleOrgs."
  }
}
variable "single_page_application" {
  type = list(object({
    redirect_uris = list(string)
  }))
  description = "This is the redirect uri field in the portal."
}
variable "storage_account_name" {
  type = string
  description = "This is the name of the storage account where the secret references will be stored"
  default = ""
}

variable "tenant_id" {
}

