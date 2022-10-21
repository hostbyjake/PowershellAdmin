
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq 'gamintern' } | Remove-CimInstance
Write-Host "Removing GAM Intern Account..."
$gamDirectoryPath =  'C:\Users\gamintern'
If ( (Test-Path $gamDirectoryPath) ) { rm -r $gamDirectoryPath  } else { Write-Host 'Directory is gone and no system traces detected!' };
