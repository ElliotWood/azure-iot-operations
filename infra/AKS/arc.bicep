// params
@minLength(5)
@maxLength(50)
@description('Specifies the name of the azure container registry.')
param clusterName string = 'acr001${uniqueString(resourceGroup().id)}' // must be globally unique

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Tier of your Azure Container Registry.')
param acrSku string = 'Basic'

// azure container registry
resource acr 'Microsoft.Kubernetes/connectedClusters@2024-07-01-preview' = {
  name: clusterName
  location: location
  sku: {
    name: acrSku
  }
  identity:{
    type:'SystemAssigned'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

