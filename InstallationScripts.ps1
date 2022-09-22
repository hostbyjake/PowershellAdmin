
######NEXTIVA
#$Nextiva = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Nextiva"}
#$Nextiva.Uninstall()
#Run above to uninstall
Invoke-WebRequest -Uri https://assets.nextiva.com/download/Nextiva-win.exe -OutFile .\NextivaONE.exe; Start-Process .\NextivaONE.exe -Wait -ArgumentList '/I .\NextivaONE.exe /quiet'


######ADOBE
