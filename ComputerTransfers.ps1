$toParse = Get-WmiObject Win32_Volume -Filter "DriveType='2'" | Select-Object 'DriveLetter'
$toParse2 = $toParse -replace ("DriveLetter")
$toParse3 = $toParse2.SubString(3)
$DriveLetter = $toParse3.TrimEnd("}")
$User =((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
$UserDir = "C:\Users\$User"
$UsbDocuments = "$DriveLetter/Documents"
$UsbDesktop = "$DriveLetter/Desktop"
$UsbPictures = "$DriveLetter/Pictures"
$UsbDownloads = "$DriveLetter/Downloads"
If ( (Test-Path $UsbDocuments) ) { Remove-Item -Recurse $UsbDocuments -Force } else { Write-Host 'Documents are not present on USB!' -Fore DarkMagenta };
If ( (Test-Path $UsbDesktop) ) { Remove-Item -Recurse $UsbDesktop -Force } else { Write-Host 'Desktop Files are not present on USB!' -Fore DarkMagenta };
If ( (Test-Path $UsbPictures) ) { Remove-Item -Recurse $UsbPictures -Force  } else { Write-Host 'Pictures are not present on USB!' -Fore DarkMagenta };
If ( (Test-Path $UsbDownloads) ) { Remove-Item -Recurse $UsbDownloads -Force  } else { Write-Host 'Downloads are not present on USB!' -Fore DarkMagenta };
Set-Location $UserDir
If ( (Test-Path 'Documents') ) { Copy-Item -Recurse 'Documents' -Destination $DriveLetter -Force } else { Write-Host 'Document Folder Not Found' -Fore DarkRed };
If ( (Test-Path 'Documents') ) { Write-Host 'Done Transfering Documents!' -Fore Green } else { Write-Host 'Could not Transfer Documents' -Fore DarkRed };
If ( (Test-Path 'Desktop') ) { Copy-Item -Recurse 'Desktop' -Destination $DriveLetter -Force } else { Write-Host 'Desktop Folder Not Found' -Fore DarkRed };
If ( (Test-Path 'Desktop') ) { Write-Host 'Done Transfering Desktop!' -Fore Green } else { Write-Host 'Could not Transfer Desktop' -Fore DarkRed };
If ( (Test-Path 'Pictures') ) { Copy-Item -Recurse 'Pictures' -Destination $DriveLetter -Force } else { Write-Host 'Picture Folder Not Found' -Fore DarkRed };
If ( (Test-Path 'Pictures') ) { Write-Host 'Done Transfering Pictures!' -Fore Green } else { Write-Host 'Could not Transfer Pictures' -Fore DarkRed };
If ( (Test-Path 'Downloads') ) { Copy-Item -Recurse 'Downloads' -Destination $DriveLetter -Force } else { Write-Host 'Download Folder Not Found' -Fore DarkRed };
If ( (Test-Path 'Downloads') ) { Write-Host 'Done Transfering Downloads!' -Fore Green } else { Write-Host 'Could not Transfer Downloads' -Fore DarkRed };
