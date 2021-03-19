
provider "azurerm" {
  version = "=1.35.0"
}

# Create a resource group
resource "azurerm_resource_group" "Test02" {
  name     = "second-steps-TFWin"
  location = var.location
}
