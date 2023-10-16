// Pre-requisites:
// Create Resource Group

param location string = resourceGroup().location

// Nerwork Security Group parameters
param nsgName string = 'nsg01'

// Network Security Group rule parameters
param nsgRuleName string = 'AllowRDPinbound'
param nsgRuleDescription string = 'Allow RDP'
param nsgRuleSourceIP string = '1.2.3.4'

// Virtual Network parameters
param vnetName string = 'vnet01'
param vnetAddressPrefix string = '10.0.0.0/16'

// Virtual Network Subnet parameters
param vnetSubnetName string = 'subnet01'
param vnetSubnetAddressPrefix string = '10.0.0.0/24'

// Virtual machine parameters
param vmName string = 'vm01'
param vmSize string = 'Standard_B1s'
@secure()
param adminUsername string
@secure()
param adminPassword string

// Public IP Address parameters
param pipName string = 'pip01'

// Network Interface parameters
param nicName string = 'nic01'

// deploy the network security group
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
}

// deploy the network security group rule
resource nsgRule 'Microsoft.Network/networkSecurityGroups/securityRules@2023-05-01' = {
  name: nsgRuleName
  parent: nsg
  properties: {
    description: nsgRuleDescription
    access: 'Allow'
    protocol: 'Tcp'
    sourcePortRange: '*'
    sourceAddressPrefix: nsgRuleSourceIP
    destinationPortRange: '3389'
    destinationAddressPrefix: '*'
    direction: 'Inbound'
    priority: 100
  }
}

// deploy the virtual network
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: vnetSubnetName
        properties: {
          addressPrefix: vnetSubnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

// deploy public ip address
resource pip 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: pipName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// deploy network interface
resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

// deploy virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter-g2'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-osdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// output the public and private ip addresses
output PublicIPAddress string = pip.properties.ipAddress
output PrivateIPAddress string = nic.properties.ipConfigurations[0].properties.privateIPAddress
