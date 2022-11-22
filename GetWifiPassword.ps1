$WifiName = Read-Host -Prompt ‘Enter Wifi Name To Get Password For’ 
netsh wlan show profile name="$WifiName" key=clear




