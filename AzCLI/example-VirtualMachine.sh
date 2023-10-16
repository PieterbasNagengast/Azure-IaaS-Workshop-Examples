#!/bin/bash

vmname="myVM"
username="azureuser"

az vm create \
    --resource-group $resourcegroup \
    --name $vmname \
    --image Win2022DatacenterGen2 \
    --public-ip-sku Standard \
    --admin-username $username \
    --secure-boot enabled \
    --size Standard_B1s \
    --storage-sku StandardSSD_LRS \
    --uefi-enabled \
    --vtpm-enabled \
    --secure-boot-enabled \