param sshKeyName string = 'sshPublicKey'
param location string = resourceGroup().location
@secure()
param optionalPublicKey string

resource sshKey 'Microsoft.Compute/sshPublicKeys@2022-03-01' = if (!empty(optionalPublicKey)) {
  name: sshKeyName
  location: location
  properties: {
    publicKey: optionalPublicKey
  }
}
resource sshKeyNew 'Microsoft.Compute/sshPublicKeys@2022-03-01' = if (empty(optionalPublicKey)) {
  name: sshKeyName
  location: location
}

output sshPublicKey string = (!empty(optionalPublicKey)) ? sshKey.properties.publicKey : sshKeyNew.properties.publicKey
