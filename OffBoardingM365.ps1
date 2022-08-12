$RequiredScopes = @("Directory.AccessAsUser.All", "Directory.ReadWrite.All", "User.ReadWrite.All", “User.Read.All”)
Connect-MgGraph -Scopes $RequiredScopes

$UserAccount = Read-Host -Prompt ('Please Enter The Account You Want To Offboard -- accountname@domain.com')

function Get-Choice
{
$selection=Read-Host "Do you want to block sign-in or delete this account? A. Block B. Delete"
Switch ($selection)
{
A {$Choice="Block"}
B {$Choice="Delete"}
}
if ($Choice -eq $null){
    Write-Host('Please Enter a valid Choice (A or B)') -Fore red
}
else {
return $Choice
}
}

function Get-Confirmation
{
$confirm=Read-Host "This will delete all of the user data, are you sure? A. Yes B. No"
Switch ($confirm)
{
A {$Confirmation="Yes"}
B {$Confirmation="No"}
}
if ($Confirmation -eq $null){
    Write-Host('Please Enter a valid Choice (A or B)') -Fore red
}
else {
return $Confirmation
}
}


$BlockOrDelete = Get-Choice

if($BlockOrDelete -eq "Delete"){
$UserConfirmation = Get-Confirmation
if($UserConfirmation -eq "Yes"){
    Write-Host("DELETING ACCOUNT ...") -ForegroundColor Red
    Remove-MgUser -UserId $UserAccount
}
elseif($UserConfirmation -eq "No"){
    Write-Host("Aborting ...") -ForegroundColor Cyan
}
} else {
     Write-Host('Blocking Account ... ') -ForegroundColor Yellow
     Update-MgUser -UserId $UserAccount -AccountEnabled $false


}
Update-MgUser -UserId $UserAccount -AccountEnabled $false
Write-Host('Account Has Been Blocked') -Fore Cyan