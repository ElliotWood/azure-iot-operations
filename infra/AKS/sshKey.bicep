param sshKeyName string = 'sshPublicKey'
param location string = resourceGroup().location

resource sshKey 'Microsoft.Compute/sshPublicKeys@2022-03-01' = {
  name: sshKeyName
  location: location
}

output sshPublicKey string =  sshKey.properties.publicKey
