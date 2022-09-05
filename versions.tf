terraform {
  experiments = [module_variable_optional_attrs]
  
  required_providers {
    azuread = {
      version = "2.22.0"
    }
    azurerm = {
      version = "3.21.1"
    }
  }

  required_version = ">=1.0.7"
}