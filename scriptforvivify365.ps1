Find-Module -Name MSOnline | Install-Module -Force 
#Installs the module needed to connect PS with M365
$MSOnlineCred = Get-Credential 
#Opens prompt for M365 Admin Credentials 
Write-Host('Provide Admin 365 Credentials..') -Fore cyan
Connect-MsolService -Credential $MSOnlineCred

function Get-Domain
{
$selection=Read-Host "Choose a Domain A. Heritage Color B. Sandream C. HQ D. Calico "
Switch ($selection)
{
A {$Chosendomain="heritagecolor.com"}
B {$Chosendomain="sandreamspecialties.com"}
C {$Chosendomain="vivifycompany.com"}
D {$Chosendomain="calico.ca"}
}
if ($Chosendomain -eq $null){
    Write-Host('Please Enter a valid Choice (A, B, C, D)') -Fore red
}
else {
return $Chosendomain
}
}
$Domain = Get-Domain
if($Domain -ne $null){
$DisplayName = Read-Host -Prompt 'Enter First and Last Name for New Account'
} else {
    $Domain = Get-Domain
    $DisplayName = Read-Host -Prompt 'Enter First and Last Name for New Account'
}

$NameSplit = $DisplayName -split " "
$FirstName = $NameSplit[0]
$LastName = $NameSplit[1]
if($LastName -eq $null){
    Write-Host('Please Enter Name in First Last (Joe Smith) format') -Fore red
}
$FirstSplit = $FirstName -split ""
$FirstLetter = $FirstSplit[1]
$UserAccount = ($FirstName + '.' + $LastName + '@' + $Domain)
if($Domain -eq $null){
    Write-Host('Error') -Fore red
} elseif ($LastName -eq $null) {
    Write-Host('Error') -Fore red    
} else {
    New-MsolUser -UserPrincipalName $UserAccount -DisplayName $DisplayName -FirstName $FirstName -LastName $LastName -UsageLocation "US" -LicenseAssignment reseller-account:SPB -ForceChangePassword $true
    Write-Host('Acccount Created') -Fore green
    return $UserAccount
}

#TO REMOVE USER CREATED
#Remove-MsolUser -UserPrincipalName $UserAccount -Force
#Write-Host('Acccount Deleted') -Fore red


#Modern Azure AD Method For 365 Creation
Install-Module AzureAD
#Installs PS Module to connect to Azure Graph Module
Connect-AzureAD
#Prompts for Azure / Office admin Credentials
function Get-Domain
{
$selection=Read-Host "Choose a Domain A. Heritage Color B. Sandream C. HQ D. Calico "
Switch ($selection)
{
A {$Chosendomain="heritagecolor.com"}
B {$Chosendomain="sandreamspecialities.com"}
C {$Chosendomain="vivifycompany.com"}
D {$Chosendomain="calico.ca"}
}
if ($Chosendomain -eq $null){
    Write-Host('Please Enter a valid Choice (A, B, C, D)') -Fore red
}
else {
return $Chosendomain
}
}
$Domain = Get-Domain
if($Domain -ne $null){
$DisplayName = Read-Host -Prompt 'Enter First and Last Name for New Account'
} else {
    $Domain = Get-Domain
    $DisplayName = Read-Host -Prompt 'Enter First and Last Name for New Account'
}

$NameSplit = $DisplayName -split " "
$FirstName = $NameSplit[0]
$LastName = $NameSplit[1]
if($LastName -eq $null){
    Write-Host('Please Enter Name in First Last (Joe Smith) format') -Fore red
}
$FirstSplit = $FirstName -split ""
$FirstLetter = $FirstSplit[1]
$UserAccount = ($FirstLetter + $LastName + '@' + $Domain)
if($Domain -eq $null){
    Write-Host('Error') -Fore red
} elseif ($LastName -eq $null) {
    Write-Host('Error') -Fore red    
} else {
    New-MsolUser -UserPrincipalName $UserAccount -DisplayName $DisplayName -FirstName $FirstName -LastName $LastName -UsageLocation "US" -LicenseAssignment reseller-account:SPB -ForceChangePassword $true
    Write-Host('Acccount Created') -Fore green
    return $UserAccount
}

