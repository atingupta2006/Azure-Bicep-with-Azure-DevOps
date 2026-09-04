@minLength(3)
@maxLength(11)
param namePrefix string

param location string = resourceGroup().location

@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param storageSku string = 'Standard_LRS'

param tags object = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
}

resource requireTagOnResources 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: '871b6d14-10aa-478d-b590-94f262ecfa99'
  scope: subscription()
}

var storageNameA = '${namePrefix}a'
var storageNameB = '${namePrefix}b'

module stA 'modules/storage.bicep' = {
  name: 'storageA'
  params: {
    storageAccountName: storageNameA
    location: location
    sku: storageSku
    tags: tags
  }
}

module stB 'modules/storage.bicep' = {
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
output policyDefinitionId string = requireTagOnResources.id
