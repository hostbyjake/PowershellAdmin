Install-Module Microsoft.Graph
$RequiredScopes = @("Directory.AccessAsUser.All", "Directory.ReadWrite.All", "User.ReadWrite.All", “User.Read.All”)
Connect-MgGraph -Scopes $RequiredScopes
#Installs the module needed to connect PS with M365
#Opens prompt for M365 Admin Credentials 
Connect-MsolService -Credential $MSOnlineCred

$Domain = 'gamweb.com'
$DisplayName = Read-Host -Prompt 'Enter First and Last Name for New Account'
$MailNickname = $DisplayName -split " "
$FirstName = $MailNickname[0]
$LastName = $MailNickname[1]
$FirstSplit = $LastName -split ""
$FirstLetter = $FirstSplit[1]
$UserPrincipalName = $FirstName + $FirstLetter + '@' + $Domain
if($LastName -eq $null){
    Write-Host('Please Enter Name in First Last (Joe Smith) format') -Fore red
    $DisplayName = Read-Host -Prompt 'Enter First and Last Name for New Account'
    $NameSplit = $DisplayName -split " "
    $LastName = $NameSplit[1]
}
$params = @{
	AccountEnabled = $true
	DisplayName = $DisplayName
	MailNickname = $FirstName
	UserPrincipalName = $UserPrincipalName
	PasswordProfile = @{
		ForceChangePasswordNextSignIn = $true
		Password = "temporarypassword2!"
	}
}


New-MgUser -BodyParameters $params

gamweb:O365_BUSINESS_PREMIUM

Write-Host('Acccount Created') -Fore green

