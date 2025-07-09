Param(
  [string]$DomainName,
  [string]$SafeModePwd
)
Install-WindowsFeature AD-Domain-Services –IncludeManagementTools
Install-ADDSForest -DomainName $DomainName `
  -SafeModeAdministratorPassword (ConvertTo-SecureString $SafeModePwd –AsPlainText –Force) `
  -InstallDns -NoRebootOnCompletion:$false 