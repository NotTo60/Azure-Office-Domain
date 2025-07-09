locals {
  location             = var.location
  rg_name              = var.rg_name
  subscription_id      = var.subscription_id
  office_public_ip     = var.office_public_ip
  office_address_space = var.office_address_space
  vpn_shared_key       = var.vpn_shared_key
  vm_admin_username    = var.vm_admin_username
  vm_admin_password    = var.vm_admin_password
  storage_account_name = var.storage_account_name
  file_share_name      = var.file_share_name
  file_quota_gb        = var.file_quota_gb
}

provider "azurerm" {
  features {}
  subscription_id = local.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = local.location
}

# VNet and Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-office"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.255.0/27"]
}

# VPN Gateway
resource "azurerm_public_ip" "pip" {
  name                = "vpn-gateway-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}
resource "azurerm_virtual_network_gateway" "vpngw" {
  name                = "vnet-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw2"
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}
resource "azurerm_local_network_gateway" "lng" {
  name                = "office-lng"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = local.office_public_ip
  address_space       = [local.office_address_space]
}
resource "azurerm_virtual_network_gateway_connection" "vpn" {
  name                       = "office-vpn-connection"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.lng.id
  type                       = "IPsec"
  connection_protocol        = "IKEv2"
  shared_key                 = local.vpn_shared_key
}

# Storage Account + Azure Files w/ AD Kerberos
resource "azurerm_storage_account" "files" {
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = local.location
  account_kind                    = "FileStorage"
  account_tier                    = "Premium"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  # Azure Files AD authentication will be configured manually after DC promotion
  # to ensure proper domain setup and avoid placeholder value issues
}
resource "azurerm_storage_share" "share" {
  name                 = local.file_share_name
  storage_account_id   = azurerm_storage_account.files.id
  quota                = local.file_quota_gb
}

# Windows DC VM
resource "azurerm_network_interface" "dcnic" {
  name                = "dcnic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_windows_virtual_machine" "dc" {
  name                  = "dc01"
  admin_username        = local.vm_admin_username
  admin_password        = local.vm_admin_password
  network_interface_ids = [azurerm_network_interface.dcnic.id]
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B1s"
  provision_vm_agent    = true
  identity {
    type = "SystemAssigned"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
}

# Note: VM extensions will be configured manually after successful deployment
# to avoid conflicts and ensure proper domain setup 