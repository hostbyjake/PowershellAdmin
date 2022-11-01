$toParse = Get-WmiObject Win32_Volume -Filter "DriveType='2'" | Select-Object 'DriveLetter'
$toParse2 = $toParse -replace ("DriveLetter")
$toParse3 = $toParse2.SubString(3)
$DriveLetter = $toParse3.TrimEnd("}")
$User =((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
$UserDir = "C:\Users\$User"
$PATH = $DriveLetter
$NameOfTransferredDir = Get-ChildItem $PATH | Sort-Object LastWriteTime | Select-Object -last 1 | Select-Object 'Name'
$toParseDir = $NameOfTransferredDir -replace ("Name")
$toParseDir2 = $toParseDir.SubString(3)
$NameOfDir = $toParseDir2.TrimEnd("}")
$DirToTransfer = "$DriveLetter\$NameOfDir"
$UnloadDocuments = "$DirToTransfer/Documents"
$UnloadDesktop = "$DirToTransfer/Desktop"
$UnloadDownloads = "$DirToTransfer/Downloads"
$UnloadPictures = "$DirToTransfer/Pictures"
$UserDocuments = "$UserDir/Documents"
$UserPictures = "$UserDir/Pictures"
$UserDesktop = "$UserDir/Desktop"
$UserDownloads = "$UserDir/Downloads"
robocopy $UnloadDocuments $UserDocuments /mt /e /b /z
robocopy $UnloadDownloads $UserDownloads /mt /e /b /z
robocopy $UnloadPictures $UserPictures /mt /e /b /z
robocopy $UnloadDesktop $UserDesktop /mt /e /b /z
