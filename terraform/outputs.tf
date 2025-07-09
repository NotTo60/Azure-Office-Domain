output "vpn_gateway_ip" { value = azurerm_public_ip.pip.ip_address }
output "dc_private_ip" { value = azurerm_network_interface.dcnic.private_ip_address }
output "files_smb_mount" {
  value = "net use Z: \\${local.storage_account_name}.file.core.windows.net\\${local.file_share_name} /u:${local.storage_account_name} <storage_key>"
} 