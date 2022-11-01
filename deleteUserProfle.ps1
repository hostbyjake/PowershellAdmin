
$NameOfAccountToDelete = 'test'
Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq $NameOfAccountToDelete } | Remove-CimInstance
Write-Host "Removing $NameOfAccountToDelete Account..."
$gamDirectoryPath =  "C:\Users\$NameOfAccountToDelete"
If ( (Test-Path $gamDirectoryPath) ) { rm -r $gamDirectoryPath  } else { Write-Host 'Directory is gone and no system traces detected!' };



systeminfo | findstr 'Physical Available'