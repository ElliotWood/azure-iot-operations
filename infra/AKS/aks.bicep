@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the AKS Cluster.')
param clusterName string = '${resourceGroup().name}aks'

@description('DNS prefix to use with the hosted Kubernetes API server FQDN.')
param dnsPrefix string = 'arcaks'

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 3

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

@description('The ID for the service principal.')
param servicePrincipalClientId string

@secure()
@description('The secret password associated with the service principal.')
param servicePrincipalClientSecret string

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string = '${resourceGroup().name}_admin'

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

@description('Log Analytics Workspace Resource ID')
param logAnalyticsWorkspaceResourceID string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-03-01' = {
  name: clusterName
  location: location
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    servicePrincipalProfile: {
      clientId: servicePrincipalClientId
      secret: servicePrincipalClientSecret
    }
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
    addonProfiles: {
      azurePolicy: {
        enabled: true
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceResourceID
        }
      }
    }
    enableRBAC: true
  }
}

output controlPlaneFQDN string = aksCluster.properties.privateFQDN
output aksClusterName string = aksCluster.name
