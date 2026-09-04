param location string = resourceGroup().location

@minLength(3)
@maxLength(24)
param storageAccountName string

@minLength(1)
param owner string

param tags object = {
  env: 'dev'
  owner: owner
  project: 'bicep-training'
}

resource requireTagOnResources 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: '871b6d14-10aa-478d-b590-94f262ecfa99'
  scope: subscription()
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

output name string = stg.name
output tags object = stg.tags
output policyDefinitionId string = requireTagOnResources.id
