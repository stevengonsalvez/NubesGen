terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.86"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.9"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  // If an environment is set up (dev, test, prod...), it is used in the application name
  environment = var.environment == "" ? "dev" : var.environment
}

resource "azurecaf_name" "resource_group" {
  name          = var.application_name
  resource_type = "azurerm_resource_group"
  suffixes      = [local.environment]
}

resource "azurerm_resource_group" "main" {
  name     = azurecaf_name.resource_group.result
  location = var.location

  tags = {
    "terraform"        = "true"
    "environment"      = local.environment
    "application-name" = var.application_name
    "nubesgen-version" = "test"
  }
}

module "application" {
  source           = "./modules/app-service"
  resource_group   = azurerm_resource_group.main.name
  application_name = var.application_name
  environment      = local.environment
  location         = var.location
}
