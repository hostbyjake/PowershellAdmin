## uses Winget (Built in Module that utilizes the API of Microsoft Store to download the needed applications for Onboardings)
winget install -e --id Microsoft.Teams --Force
Write-Host ('Installing Teams') -ForegroundColor Blue
winget install -e --id Google.Chrome --Force
Write-Host ('Installing Chrome') -ForegroundColor Blue
winget install -e --id Adobe.Acrobat.Reader.32-bit --Force
Write-Host ('Installing Adobe Acrobat Reader') -ForegroundColor Blue
winget install -e --id Dropbox.Dropbox --Force
Write-Host ('Installing Dropbox') -ForegroundColor Blue
