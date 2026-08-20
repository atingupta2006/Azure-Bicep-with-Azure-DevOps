param location string = resourceGroup().location
param storageAccountName string

param tags object = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
}

resource stg 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
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

output storageName string = stg.name
output httpsOnly bool = stg.properties.supportsHttpsTrafficOnly
output minimumTls string = stg.properties.minimumTlsVersion
