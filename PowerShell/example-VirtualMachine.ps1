## Pre-requisites
## Create Resource Group
$VerbosePreference = "Continue"
$resourceGroupName = "rg-powershell-example"
$location = "West Europe"
New-AzResourceGroup -Name $resourceGroupName -Location $location -Verbose

## Create network security group rule
$nsgRuleName = "AllowRDPinbound"
$nsgRuleDescription = "Allow RDP"
$nsgRuleSourceIP = "1.2.3.4"
$nsgRule = New-AzNetworkSecurityRuleConfig `
    -Name $nsgRuleName `
    -Description $nsgRuleDescription `
    -Access Allow `
    -Protocol Tcp `
    -SourcePortRange "*" `
    -SourceAddressPrefix $nsgRuleSourceIP `
    -DestinationPortRange "3389" `
    -DestinationAddressPrefix "*" `
    -Direction Inbound `
    -Priority 100 `
    -Verbose

## Create network security group
$nsgName = "nsg01"
$nsg = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroupName -Location $location -SecurityRules $nsgRule -Verbose

## Create Virtual Network Subnet
$subnetName = "subnet01"
$subentAddressPrefix = "10.0.0.0/24"
$subnet = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subentAddressPrefix -NetworkSecurityGroupId $nsg.Id -Verbose

## Create Virtual Network
$vnetName = "vnet01"
$vnetAddressPrefix = "10.0.0.0/16"
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $subnet -Verbose

## Create Public IP Address
$pipName = "pip01"
$pip = New-AzPublicIpAddress -Name $pipName -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static -Verbose

## Create Network Interface
$nicName = "nic01"
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -Verbose

## Create Virtual Machine config
$vmName = "vm01"
$vmSize = "Standard_B1s"
$vm = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential (Get-Credential) -ProvisionVMAgent -EnableAutoUpdate 
$vm = Set-AzVMSourceImage -VM $vm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-Datacenter-g2" -Version "latest" 
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id 
$vm = Set-AzVMOSDisk -VM $vm -Name "$vmName-osdisk" -CreateOption FromImage -StorageAccountType Standard_LRS 
$vm = Set-AzVMBootDiagnostic -VM $vm -Enable
$vm = Set-AzVMSecurityProfile -VM $vm -SecurityType TrustedLaunch
$vm = Set-AzVMUefi -VM $vm -EnableVtpm $true -EnableSecureBoot $true

## Create Virtual Machine
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vm -Verbose

## results
Write-Host "private IP address: " $nic.IpConfigurations[0].PrivateIpAddress
Write-host "public IP address: " $pip.IpAddress




