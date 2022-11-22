Set-Location C:\
Invoke-WebRequest -Uri https://iperf.fr/download/windows/iperf-3.1.3-win64.zip -Outfile iperf.zip
Expand-Archive .\iperf.zip -DestinationPath C:\
Set-Location .\iperf-3.1.3-win64\
.\iperf3.exe --client nyc.speedtest.clouvider.net
