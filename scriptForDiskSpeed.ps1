function getDiskSpeed{

    param(
        [string]$driveLetter="c:",
        [int]$sampleSize=5
        )
            
    if($driveLetter.Length -eq 1){$driveLetter+=":";}
    write-host "Obtaining disk speed of $driveLetter"        

    function isPathWritable{
            param($testPath)
            # Create random test file name
            $tempFolder=$testPath+"\getDiskSpeed\"
            $filename = "diskSpeedTest-"+[guid]::NewGuid()
            $tempFilename = (Join-Path $tempFolder $filename)
            New-Item -ItemType Directory -Path $tempFolder -Force -EA SilentlyContinue|Out-Null

            Try { 
                # Try to add a new file
                # New-Item -ItemType Directory -Path $tempFolder -Force -EA SilentlyContinue
                [io.file]::OpenWrite($tempFilename).close()
                #Write-Host -ForegroundColor Green "$testPath is writable."         
    
                # Delete test file after done
                # Remove-Item $tempFilename -Force -ErrorAction SilentlyContinue 
                
                # Set return value
                $feasible=$true;
                }
            Catch {
                # Return 'false' if there are errors
                $feasible=$false;
                }

            return $feasible;
            }

    # Check if input is a valid drive letter
    function validatePath{
        param([string]$path=$driveLetter)
        if (Test-Path $path -EA SilentlyContinue){    
            $regexValidDriveLetters="^[A-Za-z]\:{0,1}$"
            $validLocalPath=$path.SubString(0,2) -match $regexValidDriveLetters
            if ($validLocalPath){
            $GLOBAL:localPath=$true;
            write-Host "Validating path... Local directory detected."
            
            $volumeName=if($driveLetter.Length -le 2){$driveLetter+"\"}else{$driveLetter.Substring(0,3)}
            $GLOBAL:clusterSize=(Get-WmiObject -Class Win32_Volume | Where-Object {$_.Name -eq $volumeName}).BlockSize;
            write-host "Cluster size detected as $clusterSize."
                   
            $driveLettersOnThisComputer=ls function:[A-Z]: -n|?{test-path $_}
            if (!($driveLettersOnThisComputer -contains $path.SubString(0,2))){
                Write-Host "The provided local path's first 2 characters do not match any volumes in this system.";
                return $false;
                }
            return $(isPathWritable $path)
            }else{
                    $regexUncPath="^\\(?:\\[^<>:`"/\\|?*]+)+$"
                                if ($path -match $regexUncPath){
                    $GLOBAL:localPath=$False;
                    write-Host "UNC directory detected."
                    return $(isPathWritable $path)
                    }else{Write-Host "The provided path does not match a UNC pattern nor a local drive.";return $false;}
                    }
            }else{
                Write-Host "The path $path currently does NOT exist";
                Return $false;
                }
        }
    
    if (validatePath){
        # Set variables
        $tempDirectory="$driveLetter`\getDiskSpeed"
        # New-Item -ItemType Directory -Force -Path $tempDirectory|Out-Null
        $testFile="$tempDirectory`\testfile.dat"
        $processors=(Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
           
        # Ensure that diskspd.exe is available in the system
        $diskSpeedUtilityAvailable=get-command diskspd.exe -ea SilentlyContinue
        if (!($diskSpeedUtilityAvailable)){
            if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
                Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
                }    
            choco install diskspd -y;
            refreshenv;
        }  

    function getIops{
        # Sometimes, the test result throws this error "diskspd Error opening file:" if no switches were used
        # The work around is to specify more parameters
        # Other variations:
        # $testResult=diskspd.exe-d1 -o4 -t4 -b8k -r -L -w50 -c1G $testFile
        # $testResult=diskspd.exe -b4K -t1 -r -w50 -o32 -d10 -c8192 $testFile
        # Note: remove the -c option to avoid this error when running with unprivileged accounts
        # diskspd.exe : WARNING: Error adjusting token privileges for SeManageVolumePrivilege (error code: 1300)
        
        try{
            if ($localPath){
                #$expression="diskspd.exe -b8k -d1 -o$processors -t$processors -r -L -w25 -c1G $testfile";
                $expression="Diskspd.exe -b$clusterSize -d1 -h -L -o$processors -t1 -r -w30 -c1G $testfile  2>&1";
                }else{
                    $expression="Diskspd.exe -b8K -d1 -h -L -o$processors -t1 -r -w30 -c1G $testfile 2>&1";
                    }
            #write-host $expression
            $testResult=invoke-expression $expression;
            <# diskspd.exe -b8k -d1 -o4 -t4 -r -L -w25 -c1G $testfile
            8K block size; 1 second random I/O test;4 threads; 4 outstanding I/O operations;
            25% write (implicitly makes read 75% ratio); 
            #>
            }
            catch{                    
                $errorMessage = $_.Exception.Message
                $failedItem = $_.Exception.ItemName
                Write-Host "$errorMessage $failedItem";
                continue;
                }
        $x=$testResult|select-string -Pattern "total*" -CaseSensitive|select-object -First 1|out-String
        $iops=$x.split("|")[-3].Trim()
        #$mebibytesPerSecond=$x.split("|")[-4].Trim()            
        return $iops
    }
    
    function selectHighIops{
        $testArray=@();            
        for($i=1;$i -le $sampleSize;$i++){
            try{
                $iops=getIops;
                write-host "$i of $sampleSize`: $iops IOPS";
                $testArray+=$iops;
                }
                catch{
                    $errorMessage = $_.Exception.Message
                    $failedItem = $_.Exception.ItemName
                    Write-Host "$errorMessage $failedItem";
                    break;
                }
            }
        $highestResult=($testArray|measure -Maximum).Maximum
        return $highestResult
    } 
    
    # Trigger several tests and select the highest value
    $selectedIops=selectHighIops

    # Cleanup
    # cmd /c rd $tempDirectory
    function isFileLocked{
        param($file=$(New-Object System.IO.FileInfo $testFile))
        if (Test-Path $testFile){
            try {
                $fileHandle = $file.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
                if ($fileHandle){
                    # File handle is open, which means file is not locked
                    $fileHandle.Close()
                    }
                return $false
                }
            catch{
                # file is locked
                return $true
                }
            }else{return $false}
        }
    
    do {
        sleep 1;
        isFileLocked|out-null;
        }until(!(isFileLocked))
    Remove-Item -Recurse -Force $tempDirectory
    
    $mebibytesPerSecond=[math]::round($(([int]$selectedIops)/128),2)
    return "Highest: $selectedIops IOPS ($mebibytesPerSecond MiB/s)";
    }else{return "Cannot get disk speed"}
}

<#
(gwmi -Class win32_volume -Filter "DriveType!=5" -ea stop| ?{$_.DriveLetter -ne $isnull}|`
                Select-object @{Name="Letter";Expression={$_.DriveLetter}},`
                @{Name="Label";Expression={$_.Label}},`
                @{Name="Capacity";Expression={"{0:N2} GiB" -f ($_.Capacity/1073741824)}},`
                @{Name = "Available"; Expression = {"{0:N2} GiB" -f ($_.FreeSpace/1073741824)}},`
                @{Name = "Utilization"; Expression = {"{0:N2} %" -f  ((($_.Capacity-$_.FreeSpace) / $_.Capacity)*100)}},`
                @{Name = "diskBrand"; Expression = {getDiskSpeed $_.DriveLetter}},`
                @{Name = "diskSpeed"; Expression = {getDiskSpeed $_.DriveLetter}}`
                | ft -autosize | Out-String).Trim()
#>