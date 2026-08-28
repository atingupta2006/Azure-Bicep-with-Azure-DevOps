@description('Prefix; accounts are prefix + a and prefix + b.')
@minLength(3)
@maxLength(11)
param namePrefix string

param location string = resourceGroup().location

@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param storageSku string = 'Standard_GRS'

param tags object = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
}

var storageNameA = '${namePrefix}a'
var storageNameB = '${namePrefix}b'

module stA 'modules/one-storage.bicep' = {
  name: 'storageA'
  params: {
    storageAccountName: storageNameA
    location: location
    sku: storageSku
    tags: tags
  }
}

module stB 'modules/one-storage.bicep' = {
  name: 'storageB'
  params: {
    storageAccountName: storageNameB
    location: location
    sku: storageSku
    tags: tags
  }
}

output nameA string = stA.outputs.name
output nameB string = stB.outputs.name
output sku string = stA.outputs.sku
