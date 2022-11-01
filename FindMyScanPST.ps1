$Keys = Get-Item -Path HKLM:\Software\RegisteredApplications | Select-Object -ExpandProperty property
$Product = $Keys | Where-Object {$_ -Match "Excel.Application."}
$OfficeVersion = ($Product.Replace("Excel.Application.","")+".0")

$32BitOfficePath = 'C:\Program Files (x86)\Microsoft Office\'

If ( (Test-Path $32BitOfficePath) ) { $Bit = 32 } else { $Bit = 64 };

$Outlook2019 = '19.0'
$Outlook2016 = '16.0'
$Outlook2013 = '15.0'
$Outlook2010 = '14.0'
$Outlook2007 = '12.0'

if($OfficeVersion -eq $Outlook2019 -And $Bit -eq 64){
    $PathToPst = 'C:\Program Files\Microsoft Office\root\Office19'
    
} elseif($OfficeVersion -eq $Outlook2019 -And $Bit -eq 32){
    $PathToPst = 'C:\Program Files (x86)\Microsoft Office\root\Office19'
    
} elseif($OfficeVersion -eq $Outlook2016 -And $Bit -eq 64){
    $PathToPst = 'C:\Program Files\Microsoft Office\root\Office16'
    
} elseif($OfficeVersion -eq $Outlook2016 -And $Bit -eq 32){
    $PathToPst = 'C:\Program Files (x86)\Microsoft Office\Office16'
    
} elseif($OfficeVersion -eq $Outlook2013 -And $Bit -eq 64){
    $PathToPst = 'C:\Program Files\Microsoft Office 15\root\Office15'
    
} elseif($OfficeVersion -eq $Outlook2013 -And $Bit -eq 32){
    $PathToPst = 'C:\Program Files (x86)\Microsoft Office 15\root\Office15'
    
} elseif($OfficeVersion -eq $Outlook2010 -And $Bit -eq 64){
    $PathToPst = 'C:\Program Files\Microsoft Office\root\Office14'
    
} elseif($OfficeVersion -eq $Outlook2010 -And $Bit -eq 32){
    $PathToPst = 'C:\Program Files\Microsoft Office (x86)\Office14'
    
} elseif($OfficeVersion -eq $Outlook2007 -And $Bit -eq 64){
    $PathToPst = 'C:\Program Files\Microsoft Office\Office12'
    
} elseif($OfficeVersion -eq $Outlook2007 -And $Bit -eq 32){
    $PathToPst = 'C:\Program Files (x86)\Microsoft Office\Office12'
    
} else {
    Write-Host ('Error Finding Outlook Version') -Fore red
}

$User =((Get-WMIObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]

$UserPSTFile = "C:\Users\$User\AppData\Local\Microsoft\Outlook"
Write-Host ("This is the location of this users PST Data file $UserPSTFile") -ForegroundColor DarkMagenta
Set-Location -Path $PathToPst 
Start-Process ./SCANPST.exe



