@minLength(3)
@maxLength(11)
param namePrefix string

param location string = resourceGroup().location

@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param storageSku string = 'Standard_LRS'

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

param tags object = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
  workload: 'batch'
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

module compute 'modules/compute.bicep' = {
  name: 'compute'
  params: {
    location: location
    vmName: vmName
    nicName: nicName
    pipName: pipName
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags
  }
}

output nameA string = stA.outputs.name
output nameB string = stB.outputs.name
output sku string = stA.outputs.sku
output vmNameOut string = compute.outputs.vmName
output nicNameOut string = compute.outputs.nicName
output subnetId string = compute.outputs.subnetId
output policyDefinitionId string = requireTagOnResources.id
