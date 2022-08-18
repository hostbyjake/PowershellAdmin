$RequiredScopes = @("Directory.AccessAsUser.All", "Directory.ReadWrite.All", "User.ReadWrite.All", “User.Read.All”)
Connect-MgGraph -Scopes $RequiredScopes
#Calls Latest Supported Powershell Module for 365 Commands with the appropiate permissions.
#Module used is replacing legacy Azure AD & MsolService

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
#Prompts a multiple-choice selection of the appropriate domain for the new user

if($Domain -ne $null){
$DisplayName = Read-Host -Prompt 'Enter First and Last Name for New Account'
} else {
    $Domain = Get-Domain
    $DisplayName = Read-Host -Prompt 'Enter First and Last Name for New Account'
}
#Prompts for User First and Last Name if no errors

$NameSplit = $DisplayName -split " "
$FirstName = $NameSplit[0]
$LastName = $NameSplit[1]
if($LastName -eq $null){
    Write-Host('Please Enter Name in First Last (Joe Smith) format') -Fore red
}
$FirstSplit = $FirstName -split ""
$FirstLetter = $FirstSplit[1]
$MailNickname = $FirstName
$UserAccount = ($FirstName + '.' + $LastName + '@' + $Domain)
#Pulls First and Last Name into seperate variables

$params = @{
	AccountEnabled = $true
	DisplayName = $DisplayName
	MailNickname = $MailNickname
	UserPrincipalName = $UserAccount
	PasswordProfile = @{
		ForceChangePasswordNextSignIn = $true
		Password = "temporarypassword2!"
	}
}
#The user params for the new account
if($Domain -eq $null){
    Write-Host('Error') -Fore red
} elseif ($LastName -eq $null) {
    Write-Host('Error') -Fore red    
} else {
  New-MgUser -BodyParameter $params
}
#If no errors, make the account!
