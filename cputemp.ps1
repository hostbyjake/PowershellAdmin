function Get-Temperature {
    $t = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi"
    $returntemp = @()

    foreach ($temp in $t.CurrentTemperature)
    {


    $currentTempKelvin = $temp / 10
    $currentTempCelsius = $currentTempKelvin - 273.15

    $currentTempFahrenheit = (9/5) * $currentTempCelsius + 32

    $currentTempCelsiusRounded = [math]::Round($currentTempCelsius)
    
    $currentTempFarenheightRounded = [math]::Round($currentTempFahrenheit)

    $returntemp += $currentTempCelsiusRounded.ToString() + " C / " + $currentTempFarenheightRounded.ToString() + " F "
    }
    return $returntemp
}

Get-Temperature



