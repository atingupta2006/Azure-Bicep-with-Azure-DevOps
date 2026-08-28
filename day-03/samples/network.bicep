param location string = resourceGroup().location
param vnetName string = 'vnet-bicep-uXX'
param vnetAddressPrefix string = '10.30.0.0/16'
param nsgName string = 'nsg-app-uXX'
param appSubnetName string = 'snet-app-uXX'
param mgmtSubnetName string = 'snet-mgmt-uXX'

param tags object = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
}

var subnets = [
  {
    name: appSubnetName
    addressPrefix: '10.30.1.0/24'
    attachNsg: true
  }
  {
    name: mgmtSubnetName
    addressPrefix: '10.30.2.0/24'
    attachNsg: false
  }
]

var nsgRules = [
  {
    name: 'AllowSSH'
    priority: 1000
    access: 'Allow'
    destinationPortRange: '22'
  }
  {
    name: 'DenyRDP'
    priority: 4096
    access: 'Deny'
    destinationPortRange: '3389'
  }
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [for r in nsgRules: {
      name: r.name
      properties: {
        priority: r.priority
        protocol: 'Tcp'
        access: r.access
        direction: 'Inbound'
        sourceAddressPrefix: '*'
        sourcePortRange: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: r.destinationPortRange
      }
    }]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [for s in subnets: {
      name: s.name
      properties: union({
        addressPrefix: s.addressPrefix
      }, s.attachNsg ? {
        networkSecurityGroup: {
          id: nsg.id
        }
      } : {})
    }]
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
output appSubnetId string = vnet.properties.subnets[0].id
output mgmtSubnetId string = vnet.properties.subnets[1].id
output nsgName string = nsg.name
