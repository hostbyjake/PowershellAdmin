
######NEXTIVA
#$Nextiva = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Nextiva"}
#$Nextiva.Uninstall()
#Run above to uninstall
Invoke-WebRequest -Uri https://assets.nextiva.com/download/Nextiva-win.exe -OutFile .\NextivaONE.exe; Start-Process .\NextivaONE.exe -Wait -ArgumentList '/I .\NextivaONE.exe /quiet'


######ADOBE
Invoke-WebRequest -Uri 'https://bsgtech.sharepoint.com/:u:/s/Engineering/EUnsM0yHgvNNgm4QKZl0jIgBnLIjGHrD9NvKhswSxa5z3A?e=dAShKt' 