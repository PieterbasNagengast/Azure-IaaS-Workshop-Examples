// Pre-requisites:
// Create Resource Group

param location string = resourceGroup().location
param storageAccountNamePrefix string = 'sabicep'
param storageAccountContainerName string = 'mycontainer'
param storageAccountShareName string = 'myshare'

var storageAccountName = take('${storageAccountNamePrefix}${uniqueString(resourceGroup().id)}', 24)

// Create Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// Create Storage Account blob services
resource storageBlobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  name: 'default'
  parent: storageAccount
}

// Create Storage Container
resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: storageAccountContainerName
  parent: storageBlobServices
}

// Create Storage Account File Services
resource storageFileServices 'Microsoft.Storage/storageAccounts/fileServices@2021-08-01' = {
  name: 'default'
  parent: storageAccount
}

// Create File Share
resource storageFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-08-01' = {
  name: storageAccountShareName
  parent: storageFileServices
}
