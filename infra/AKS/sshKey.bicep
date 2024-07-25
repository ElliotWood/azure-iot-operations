param sshKeyName string = 'sshPublicKey'
param location string = resourceGroup().location

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

resource sshKey 'Microsoft.Compute/sshPublicKeys@2022-03-01' = {
  name: sshKeyName
  location: location
  properties: {
    publicKey: sshRSAPublicKey
  }
}

output sshPublicKey string = sshKey.properties.publicKey
