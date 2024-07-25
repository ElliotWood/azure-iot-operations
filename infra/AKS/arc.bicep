param location string = resourceGroup().location
param clusterName string

resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2024-07-01-preview' = {
  name: clusterName
  location: location
  properties: {
    publicKeys: []
  }
}
