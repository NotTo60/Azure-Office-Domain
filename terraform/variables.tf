variable "location" { default = "westeurope" }
variable "rg_name" { default = "rg-accounting-office" }
variable "subscription_id" { default = "ddb0e579-48f3-45d6-90c2-9544e367fda8" }
variable "office_public_ip" { description = "Your office public IP" }
variable "office_address_space" { description = "Office LAN CIDR (e.g., 192.168.1.0/24)" }
variable "vpn_shared_key" {
  description = "PSK for VPN"
  type        = string
}

variable "vm_admin_username" { default = "azureadmin" }
variable "vm_admin_password" {
  description = "Strong password"
  type        = string
}

variable "storage_account_name" { default = "acctfiles01" }
variable "file_share_name" { default = "sharedfiles" }
variable "file_quota_gb" { default = 2048 } 