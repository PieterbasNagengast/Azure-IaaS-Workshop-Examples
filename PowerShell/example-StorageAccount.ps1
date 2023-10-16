## Pre-requisites
## Create Resource Group
$VerbosePreference = "Continue"
$resourceGroupName = "rg-powershell-example"
$location = "West Europe"
New-AzResourceGroup -Name $resourceGroupName -Location $location

## Check Storage Account name availability
$name = "sapowershell$(Get-Random)"
Get-AzStorageAccountNameAvailability -Name $name

## Create Storage Account
$skuName = "Standard_LRS"
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $name -SkuName $skuName -Location $location -Verbose

## Get Storage Account Keys
$storageAccountKey = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccount.StorageAccountName -Verbose

## Create Storage Account Context
$storageAccountContext = New-AzStorageContext -StorageAccountName $storageAccount.StorageAccountName -StorageAccountKey $storageAccountKey.Value[0]  -Verbose

## Create Blob Container
$containerName = "mycontainer"
New-AzStorageContainer -Name $containerName -Context $storageAccountContext -Permission Blob -Verbose

## Upload Blob
$localFile = ".\azure.png"
$blob = Set-AzStorageBlobContent -File $localFile -Container $containerName -Context $storageAccountContext -Verbose


## List Blobs
Get-AzStorageBlob -Container $containerName -Context $storageAccountContext -Verbose

## Create File Share
$fileShareName = "myshare"
New-AzStorageShare -Name $fileShareName -Context $storageAccountContext -Verbose

## Upload File
$localFile = ".\azure.png"
Set-AzStorageFileContent -ShareName $fileShareName -Source $localFile -Context $storageAccountContext -Verbose

write-host "URL to Blob file:" $blob.ICloudBlob.Uri.AbsoluteUri