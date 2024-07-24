param location string = resourceGroup().location
param clusterName string
param resourceGroup string = resourceGroup().name

resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2020-10-01' = {
  name: clusterName
  location: location
  properties: {
    publicKeys: []
  }
}

resource arcResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroup
  location: location
}
