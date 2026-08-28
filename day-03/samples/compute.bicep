param location string = resourceGroup().location
param vmName string
param nicName string
param pipName string

@allowed([
  'Standard_B1s'
  'Standard_B2s'
])
param vmSize string = 'Standard_B1s'

param adminUsername string = 'azureuser'

@secure()
param adminPassword string

param sharedNetworkRg string = 'rg-bicep-shared'
param sharedVnetName string = 'vnet-bicep-shared'
param sharedAppSubnetName string = 'snet-app-shared'

param tags object = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
}

resource sharedVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: sharedVnetName
  scope: resourceGroup(sharedNetworkRg)
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: sharedVnet
  name: sharedAppSubnetName
}

resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: pipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: tags
}

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: appSubnet.id
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

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
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
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output vmName string = vm.name
output vmId string = vm.id
output nicName string = nic.name
output pipName string = pip.name
output subnetId string = appSubnet.id
