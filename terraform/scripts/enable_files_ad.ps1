Param($RG, $StorageAccount, $Domain)
Install-Module -Name Az.Storage -Force -Scope AllUsers
Import-Module Az.Storage
$ctx = Get-AzStorageAccount -ResourceGroupName $RG -Name $StorageAccount
Install-Module -Name AzFilesHybrid -Force -Scope AllUsers
Import-Module AzFilesHybrid
# Join Storage Account to AD
Join-AzStorageAccount -ResourceGroupName $RG -Name $StorageAccount `
  -DirectoryType ADDS -DomainName $Domain `
  -AccountType ComputerObject 