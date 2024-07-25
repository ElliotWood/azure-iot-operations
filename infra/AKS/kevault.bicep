@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the Key Vault.')
param keyVaultName string = '${resourceGroup().name}kv'

@description('Tenant ID of the service principal.')
param tenantId string = tenant().tenantId

@description('Client ID of the service principal.')
param servicePrincipalClientId string

@secure()
@description('The secret password associated with the service principal.')
param servicePrincipalClientSecret string

@secure()
@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshPublicKey string

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: servicePrincipalClientId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'backup'
            'restore'
            'recover'
            'purge'
          ]
        }
      }
    ]
  }
}

resource clientIdSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: 'servicePrincipalClientId'
  parent: keyVault
  properties: {
    value: servicePrincipalClientId
  }
}
resource clientSecretSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: 'servicePrincipalClientSecret'
  parent: keyVault
  properties: {
    value: servicePrincipalClientSecret
  }
}

resource sshKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: 'sshPublicKey'
  parent: keyVault
  properties: {
    value: sshPublicKey
  }
}

output keyVaultName string = keyVault.name
