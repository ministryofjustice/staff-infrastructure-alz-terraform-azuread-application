terraform {
  experiments = [module_variable_optional_attrs]
  
  required_providers {
    azuread = {
      version = "2.26.1"
    }
    azurerm = {
      version = "2.80.0"
    }
  }

  required_version = ">=1.0.7"
}