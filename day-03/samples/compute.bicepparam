using 'compute.bicep'

param vmName = 'vm-bicep-uXX'
param nicName = 'nic-vm-uXX'
param pipName = 'pip-vm-uXX'
param vmSize = 'Standard_B1s'
param adminPassword = ''
param tags = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
}
