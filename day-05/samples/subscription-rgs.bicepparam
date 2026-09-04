using 'subscription-rgs.bicep'

param rgNameA = 'rg-bicep-uXX-sub-a'
param rgNameB = 'rg-bicep-uXX-sub-b'
param location = 'eastus'
param tags = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
}
