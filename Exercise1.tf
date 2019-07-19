/*
provider
resource group
storage account
virtual network
subnet
public ip
network interface
virtual machine
*/

locals {
  locationName = "WestUS2"
  rgName = "Terraform_Tester"
}

// Provider
provider "azurerm" {
  version = "1.28.0"
}

// Resource Group
resource "azurerm_resource_group" "wano" {
  name = local.rgName
  location = local.locationName
}

// Storage Account
resource "azurerm_storage_account" "wanosa" {
  name = "saafzalwanotest"
  resource_group_name = local.rgName    
  location = local.locationName
  account_tier = "Standard"
  account_replication_type = "LRS"      
}

// Virtual Network
resource "azurerm_virtual_network" "wanovnet" {
  name = "vnet1afzalwanotest"
  location = azurerm_resource_group.wano.location
  resource_group_name = azurerm_resource_group.wano.name
  address_space = ["10.0.0.0/16"]  
}

// Subnet
resource "azurerm_subnet" "wanosubnet" {
  name = "subnetafzalwanotest"
  resource_group_name = azurerm_resource_group.wano.name
  virtual_network_name = azurerm_virtual_network.wanovnet.name
  address_prefix = "10.0.1.0/24"  
}

// Public IP
resource "azurerm_public_ip" "wanoip" {
  name = "pubipafzalwanotest"
  location = azurerm_resource_group.wano.location
  resource_group_name = azurerm_resource_group.wano.name
  allocation_method = "Dynamic"
}

// Network Interface
resource "azurerm_network_interface" "wanonetworkint" {
  name = "networkintafzalwanotest"
  location = azurerm_resource_group.wano.location
  resource_group_name = azurerm_resource_group.wano.name
  
  ip_configuration {
    name = "wanoipconfig1"
    subnet_id = azurerm_subnet.wanosubnet.id
    private_ip_address = "10.0.1.5"
    private_ip_address_allocation = "Static"
    public_ip_address_id = azurerm_public_ip.wanoip.id
  }
}

// Virtual Machine
resource "azurerm_virtual_machine" "wanovm" {
  name = "vmam01"
  location = azurerm_resource_group.wano.location
  resource_group_name = azurerm_resource_group.wano.name
  network_interface_ids = [azurerm_network_interface.wanonetworkint.id]
  vm_size = "Standard_D2S_V3"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2016-Datacenter"
    version = "latest"
  }
  storage_os_disk{
    name = "vmam01-disk1"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile{
    computer_name = "vmam01"
    admin_username = "wanoadmin"
    admin_password = "P@ssw0rd1234"
  }
  os_profile_windows_config{
    provision_vm_agent = true
    enable_automatic_upgrades = false
  }
  boot_diagnostics{
    enabled = "true"
    storage_uri = join(",", azurerm_storage_account.wanosa.*.primary_blob_endpoint)
  }
}
