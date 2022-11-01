net user scan scantofolder2! /expires:never /add
#Makes the Scan User - Assigns default password - Change above if desired.
$computername = hostname
$User =((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
$UserDir = "C:\Users\$User"
#Pulls the computer name, user on the computer, to put the scan folder in the local directory

$companyToParse = Get-ChildItem $UserDir| Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match "OneDrive - "} | Select-Object Name
$parsedStepOne = $companyToParse -replace ("Name")
$parsedStepTwo = $parsedStepOne.SubString(3)
$Company = $parsedStepTwo.TrimEnd("}")
#Pulls the OneDrive location for each unique client with no intervention needed

mkdir “$UserDir\scans”

New-Item -ItemType SymbolicLink -Path "$UserDir\$Company\scans" -Target "$UserDir\scans"
#Backs up to cloud

New-SmbShare -Name "Scan" -Path "$UserDir\scans\" -FullAccess "$computername\Scan"
#Makes the SMB Share 'Scan'
$Path = $UserDir + '\scans'
$ACL = Get-Acl -Path $PATH
$identity = "scan"
$fileSystemRights = "FullControl"
$type = "Allow"
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
$ACL.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path $PATH -AclObject $ACL
#Assigns full control to the Scan User
#If you go to properties - it will only show the Allow box checked under 'Special Permissions' at the bottom
#This may seem like the script did not assign full control - but if you check under the special permissions
#You will see it has allow for full control - the functionality is exactly the same
