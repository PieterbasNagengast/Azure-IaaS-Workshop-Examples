#!/bin/bash

resourcegroup="rg-azcli-example"
vmname="myVM"
username="azureuser"

az vm create \
    --resource-group $resourcegroup \
    --name $vmname \
    --image "MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:20348.1006.220908" \
    --public-ip-sku Standard \
    --admin-username $username \
    --secure-boot enabled \
    --size Standard_B1s \
    --storage-sku StandardSSD_LRS \
    --security-type "TrustedLaunch" \
    --enable-secure-boot true \
    --enable-vtpm true 
