param sshKeyName string = 'sshPublicKey${resourceGroup()}'
param location string = resourceGroup().location
@secure()
param optionalPublicKey string = ''

resource sshKey 'Microsoft.Compute/sshPublicKeys@2022-03-01' = {
  name: sshKeyName
  location: location
  properties: {
    publicKey: optionalPublicKey
  }
}

output sshPublicKey string = sshKey.properties.publicKey
