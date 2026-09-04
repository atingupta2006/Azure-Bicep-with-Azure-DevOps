using 'main.bicep'

param namePrefix = 'stb26uXX'
param storageSku = 'Standard_LRS'
param vmName = 'vm-bicep-uXX'
param nicName = 'nic-vm-uXX'
param pipName = 'pip-vm-uXX'
param vmSize = 'Standard_B1s'
param adminPassword = ''
param tags = {
  env: 'dev'
  owner: 'uXX'
  project: 'bicep-training'
  workload: 'batch'
}
