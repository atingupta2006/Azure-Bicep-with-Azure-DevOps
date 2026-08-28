param sharedNetworkRg string = 'rg-bicep-shared'
param sharedVnetName string = 'vnet-bicep-shared'
param sharedAppSubnetName string = 'snet-app-shared'
param sharedMgmtSubnetName string = 'snet-mgmt-shared'
param sharedNsgName string = 'nsg-app-shared'

resource sharedVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: sharedVnetName
  scope: resourceGroup(sharedNetworkRg)
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: sharedVnet
  name: sharedAppSubnetName
}

resource mgmtSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: sharedVnet
  name: sharedMgmtSubnetName
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing = {
  name: sharedNsgName
  scope: resourceGroup(sharedNetworkRg)
}

output vnetId string = sharedVnet.id
output appSubnetId string = appSubnet.id
output mgmtSubnetId string = mgmtSubnet.id
output addressPrefixes array = sharedVnet.properties.addressSpace.addressPrefixes
output nsgId string = appNsg.id
output appSubnetNsgId string = appSubnet.properties.networkSecurityGroup.id
