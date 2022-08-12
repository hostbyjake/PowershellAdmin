# Don't run as admin
# Run as user, won't work backstage
# Edits the Regedit for the common Outlook fix we manually have to do to update the 50gb limit to 100gb
$Keys = Get-Item -Path HKLM:\Software\RegisteredApplications | Select-Object -ExpandProperty property
$Product = $Keys | Where-Object {$_ -Match "Excel.Application."}
$OfficeVersion = ($Product.Replace("Excel.Application.","")+".0")
Write-Host $OfficeVersion

$registryPath =  -join(‘HKCU:\Software\Microsoft\Office\’, $OfficeVersion, ‘\Outlook\PST’)
If ( !(Test-Path $registryPath) ) { New-Item -Path $registryPath -Force; };
New-ItemProperty -Path $registryPath -Name “MaxFileSize” -Value 100000 -PropertyType DWORD -Force
New-ItemProperty -Path $registryPath -Name “MaxLargeFileSize” -Value 102400 -PropertyType DWORD -Force
New-ItemProperty -Path $registryPath -Name “WarnLargeFileSize” -Value 97280 -PropertyType DWORD -Force
