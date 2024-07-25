param location string = resourceGroup().location
param clusterName string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2022-10-01-preview' = {
  name: clusterName
  location: location
  identity:{
    type:'SystemAssigned'
  }
  properties: {
    agentPublicKeyCertificate: sshRSAPublicKey
  }
}
