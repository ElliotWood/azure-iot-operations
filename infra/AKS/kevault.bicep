@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the Key Vault.')
param keyVaultName string = 'myKeyVault'

@description('Client ID of the service principal.')
param clientId string

@description('Tenant ID of the service principal.')
param tenantId string

@description('Secret values to store in the Key Vault.')
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
        objectId: clientId
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

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = [for secretName in secrets.keys(): {
  name: '${keyVault.name}/${secretName}'
  properties: {
    value: secrets[secretName]
  }
}]
