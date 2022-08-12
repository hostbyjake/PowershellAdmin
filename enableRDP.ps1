netsh advfirewall firewall set rule group="Remote Desktop" new enable=Yes
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
sc config termservice start= auto
net start termservice