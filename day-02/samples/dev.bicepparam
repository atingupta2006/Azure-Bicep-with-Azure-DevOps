using 'env-template.bicep'

param storageAccountName = 'stb26uXX'
param storageSku = 'Standard_LRS'
param tags = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
}
