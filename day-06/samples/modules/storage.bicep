@description('Storage account name (3–24 lowercase letters and numbers).')
@minLength(3)
@maxLength(24)
param storageAccountName string

param location string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
param sku string = 'Standard_LRS'

param tags object

resource stg 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
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
output id string = stg.id
output sku string = stg.sku.name
