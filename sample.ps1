#Find-Module -Name MSOnline | Install-Module -Force 
#Installs the module needed to connect PS with M365
#$MSOnlineCred = Get-Credential 
#Opens prompt for M365 Admin Credentials 
#Write-Host('Provide Admin 365 Credentials..') -Fore cyan
Connect-MsolService -Credential $MSOnlineCred

Get-MsolUser
#Provides Existing Users
$UserAccount = Read-Host -Prompt ('Please Enter The Account You Want To Block -- accountname@domain.com')
#Set-MsolUser -UserPrincipalName $UserAccount -BlockCredential $true
Write-Host('Account Has Been Blocked') -Fore Cyan