$EdgeHome = 'HKCU:\Software\Policies\Microsoft\Edge'
If ( -Not (Test-Path $EdgeHome)) {
  New-Item -Path $EdgeHome | Out-Null
}
# Set RestoreOnStartup value entry
$IPHT = @{
  Path   = $EdgeHome 
  Name   = 'RestoreOnStartup' 
  Value  = 4 
  Type   = 'DWORD'
}
Set-ItemProperty @IPHT -verbose
# Create Startup URL's registry key
$EdgeSUURL = "$EdgeHome\RestoreOnStartupURLs"
If ( -Not (Test-Path $EdgeSUURL)) {
  New-Item -Path $EdgeSUURL | Out-Null
}
# Create a single URL startup page
Set-ItemProperty -Path $EdgeSUURL -Name '1' -Value $url