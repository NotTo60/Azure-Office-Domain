# Azure Office Domain

This project automates the deployment of a secure Azure environment for a small office, including:
- Virtual Network (VNet) and subnets
- Site-to-site VPN gateway
- Windows Server VM (auto-promotes to Domain Controller)
- Azure Files Premium storage with AD DS integration
- Example scripts for drive mapping

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription with sufficient permissions

## Setup Instructions
1. Clone this repository:
   ```sh
   git clone https://github.com/YOUR-USERNAME/Azure-Office-Domain.git
   cd Azure-Office-Domain/terraform
   ```
2. Update `terraform.tfvars` with your real values (all current values are dummies and must be replaced).
3. Login to Azure:
   ```sh
   az login
   ```
4. Initialize Terraform:
   ```sh
   terraform init
   ```
5. Review the plan:
   ```sh
   terraform plan
   ```
6. Apply the deployment:
   ```sh
   terraform apply -auto-approve
   ```

## Security Warning
**Do NOT use the dummy credentials or IPs in production. Always replace them with your real, secure values before deploying.**

## Cleanup
To destroy all resources:
```sh
terraform destroy -auto-approve
``` 