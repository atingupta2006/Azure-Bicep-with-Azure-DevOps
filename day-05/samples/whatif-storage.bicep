param location string = resourceGroup().location

@minLength(3)
@maxLength(11)
param namePrefix string

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

var storageAccountName = '${namePrefix}q'

resource stg 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  tags: tags
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    defaultToOAuthAuthentication: true
  }
}

output name string = stg.name
output sku string = stg.sku.name
