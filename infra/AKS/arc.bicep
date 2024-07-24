param location string = resourceGroup().location
param clusterName string

resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2020-10-01' = {
  name: clusterName
  location: location
  properties: {
    publicKeys: []
  }
}
