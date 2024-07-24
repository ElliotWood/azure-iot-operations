@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the Log Analytics Workspace.')
param workspaceName string = 'logAnalyticsWorkspace'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output workspaceId string = logAnalyticsWorkspace.id
