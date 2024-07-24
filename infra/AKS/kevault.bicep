@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the Key Vault.')
param keyVaultName string = '${resourceGroup().name}kv'

@description('Client ID of the service principal.')
param servicePrincipalClientId string

@description('Tenant ID of the service principal.')
param tenantId string = tenant().tenantId

@description('Secret values to store in the Key Vault.')
@secure()
param secrets object

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

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = [for secret in items(secrets): {
  name: secret.key
  parent: keyVault
  properties: {
    value: secret.value
  }
}]

output keyVaultName string = keyVault.name
