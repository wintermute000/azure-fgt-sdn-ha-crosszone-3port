terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  
  backend "azurerm" {

  }

  required_version = ">= 0.13"
}
