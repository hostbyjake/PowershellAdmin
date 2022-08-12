New-AzVM -ResourceGroupName [sandbox resource group name] -Name 'testVM' -Credential (Get-Credential) -Location 'East US' -Image UbuntuLTS -OpenPorts 22 -PublicIpAddressName 'BSGTECH'
