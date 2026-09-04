targetScope = 'subscription'

param rgNameA string
param rgNameB string
param location string = 'eastus'

param tags object = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
}

resource rgA 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgNameA
  location: location
  tags: tags
}

resource rgB 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgNameB
  location: location
  tags: tags
}

output rgNameA string = rgA.name
output rgNameB string = rgB.name
