using 'env-template.bicep'

param storageAccountName = 'stb26uXX'
param storageSku = 'Standard_GRS'
param tags = {
  env: 'test'
  owner: 'uXX'
  project: 'bicep-training'
}
