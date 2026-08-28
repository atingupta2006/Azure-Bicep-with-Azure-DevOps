using 'network.bicep'

param vnetName = 'vnet-bicep-uXX'
param nsgName = 'nsg-app-uXX'
param appSubnetName = 'snet-app-uXX'
param mgmtSubnetName = 'snet-mgmt-uXX'
param tags = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
}
