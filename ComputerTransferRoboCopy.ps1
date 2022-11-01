$toParse = Get-WmiObject Win32_Volume -Filter "DriveType='2'" | Select-Object 'DriveLetter'
$toParse2 = $toParse -replace ("DriveLetter")
$toParse3 = $toParse2.SubString(3)
$DriveLetter = $toParse3.TrimEnd("}")
$User =((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
$UserDir = "C:\Users\$User"
$UsbUserDir = "$DriveLetter/$User"
mkdir $UsbUserDir
$UsbDocuments = "$UsbUserDir/Documents"
$UsbDesktop = "$UsbUserDir/Desktop"
$UsbPictures = "$UsbUserDir/Pictures"
$UsbDownloads = "$UsbUserDir/Downloads"
Set-Location $UserDir
If ( (Test-Path 'Documents') ) { robocopy 'Documents' $UsbDocuments /mt /e /b /z } else { Write-Host 'Document Folder Not Found' -Fore DarkRed };
If ( (Test-Path 'Documents') ) { Write-Host 'Done Transfering Documents!' -Fore Green } else { Write-Host 'Could not Transfer Documents' -Fore DarkRed };
If ( (Test-Path 'Desktop') ) { robocopy 'Desktop' $UsbDesktop /mt /e /b /z } else { Write-Host 'Desktop Folder Not Found' -Fore DarkRed };
If ( (Test-Path 'Desktop') ) { Write-Host 'Done Transfering Desktop!' -Fore Green } else { Write-Host 'Could not Transfer Desktop' -Fore DarkRed };
If ( (Test-Path 'Pictures') ) { robocopy 'Pictures' $UsbPictures /mt /e /b /z } else { Write-Host 'Picture Folder Not Found' -Fore DarkRed };
If ( (Test-Path 'Pictures') ) { Write-Host 'Done Transfering Pictures!' -Fore Green } else { Write-Host 'Could not Transfer Pictures' -Fore DarkRed };
If ( (Test-Path 'Downloads') ) { robocopy 'Downloads' $UsbDownloads /mt /e /b /z } else { Write-Host 'Download Folder Not Found' -Fore DarkRed };
If ( (Test-Path 'Downloads') ) { Write-Host 'Done Transfering Downloads!' -Fore Green } else { Write-Host 'Could not Transfer Downloads' -Fore DarkRed };
