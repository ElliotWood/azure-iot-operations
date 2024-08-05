# azure-iot-operations

## Overview

This repo contains the deployment definition of Azure IoT Operations (AIO) and allows for
AIO to be deployed to an Arc-enabled K8s cluster. This repository does not encourage pull requests, as the repo is
meant for publicly sharing the releases of AIO and not shared development of AIO.

Please see the [Azure IoT Operations documentation](https://aka.ms/AIOdocs) for more information. To learn how to
deploy AIO using GitOps, see the [Deploy to cluster documentation](https://learn.microsoft.com/en-us/azure/iot-operations/deploy-iot-ops/howto-deploy-iot-operations?tabs=github#deploy-extensions).

## Prereq

- Docker
- Azure cli
- choco install kubernetes-cli
- choco install k3d

1. Az Login

    | **No** | **Subscription name** | **Subscription ID** | **Tenant** |
    | -----  | ------------------------------------  | ------------------------------------  | -------------- |
    | [1]    | LAB3-Sensormine                       | ddb57ff2-ff23-4732-9730-77d3394019e6  | LAB3 PTY. LTD. |
    | [2] *  | SensorMine-Development                | 5f5dd16b-0879-4c86-884f-30347411b95f  | lab3sensormine |
    | [3]    | Visual Studio Enterprise Subscrip...  | a1039d76-c132-4a47-947a-519d0bcc2bb0  | LAB3 PTY. LTD. |

2. Set account

    ```bash
    az account set -s 5f5dd16b-0879-4c86-884f-30347411b95f
    ```

3. Create RBAC owner

    ```bash
    az ad sp create-for-rbac --name iotopsownersp --role owner --scopes /subscriptions/5f5dd16b-0879-4c86-884f-30347411b95f --json-auth  
    ```

    ```bash
    # omitted
    ```

4. Set extentions once per subscription

    ```bash
    az provider register -n "Microsoft.ExtendedLocation"
    az provider register -n "Microsoft.Kubernetes"
    az provider register -n "Microsoft.KubernetesConfiguration"
    az provider register -n "Microsoft.IoTOperationsOrchestrator"
    az provider register -n "Microsoft.IoTOperationsMQ"
    az provider register -n "Microsoft.IoTOperationsDataProcessor"
    az provider register -n "Microsoft.DeviceRegistry"
    ```

5. Create AKS Cluster
6. Connect AKS CLuster to ARC

    ```bash
    az connectedk8s connect --name "arctest003aks" --resource-group "arctest003" --location "eastus" --correlation-id "c18ab9d0-685e-48e7-ab55-12588447b0ed" --tags "Datacenter City StateOrDistrict CountryOrRegion"
    ```

7. Deploy cluster-connect custom-locations Extetion via ARC
    1. Azure CLI (cloud)

        ```bash
        elliot [ ~ ]$ az connectedk8s enable-features -n arctest003aks -g arctest003 --features cluster-connect custom-locations
        The command requires the extension connectedk8s. Do you want to install it now? The command will continue to run after the extension is installed. (Y/n): y
        Run 'az config set extension.use_dynamic_install=yes_without_prompt' to allow installing extensions without prompt.
        Default enabled including preview versions for extension installation now. Disabled in future release. Use '--allow-preview true' to enable it specifically if needed. Use '--allow-preview false' to install stable version only. 
        This command is in preview and under development. Reference and support levels: https://aka.ms/CLI_refstatus
        This operation might take a while...

        Step: 2024-08-02T04-13-43Z: Validating custom access token
        Step: 2024-08-02T04-13-44Z: Checking Microsoft.ExtendedLocation RP Registration state for this Subscription, and get OID, if registered 
        Step: 2024-08-02T04-13-46Z: Setting KubeConfig
        Step: 2024-08-02T04-13-47Z: Checking Connectivity to Cluster
        Step: 2024-08-02T04-13-48Z: Install Helm client if it does not exist
        Downloading helm client for first time. This can take few minutes...
        Step: 2024-08-02T04-13-49Z: Get namespace of release: azure-arc
        Step: 2024-08-02T04-13-57Z: Getting HelmPackagePath from Arc DataPlane
        Step: 2024-08-02T04-13-58Z: Determine Helmchart Export Path
        Step: 2024-08-02T04-13-58Z: Pulling HelmChart: mcr.microsoft.com/azurearck8s/batch1/stable/azure-arc-k8sagents, Version: 1.18.2
        "Successsfully enabled features: ['cluster-connect', 'custom-locations'] for the Connected Cluster arctest003aks"
        elliot [ ~ ]$ 
        ```

    2. Azure CLI (on prem / docker)

        ```bash
        PS C:\Users\ElliotWood> az connectedk8s enable-features -n arctest002arc -g arctest002 --features cluster-connect custom-locations
        D:\a\_work\1\s\build_scripts\windows\artifacts\cli\Lib\site-packages\cryptography/hazmat/backends/openssl/backend.py:17: UserWarning: You are using cryptography on a 32-bit Python on a 64-bit Windows Operating System. Cryptography will be significantly faster if you switch to using a 64-bit Python.
        This command is in preview and under development. Reference and support levels: https://aka.ms/CLI_refstatus
        This operation might take a while...

        Step: 2024-08-02T04-11-37Z: Validating custom access token
        Step: 2024-08-02T04-11-38Z: Checking Microsoft.ExtendedLocation RP Registration state for this Subscription, and get OID, if registered
        Step: 2024-08-02T04-11-40Z: Setting KubeConfig
        Step: 2024-08-02T04-11-40Z: Checking Connectivity to Cluster
        Step: 2024-08-02T04-11-40Z: Install Helm client if it does not exist
        Step: 2024-08-02T04-11-40Z: Get namespace of release: azure-arc
        Step: 2024-08-02T04-11-43Z: Getting HelmPackagePath from Arc DataPlane
        Step: 2024-08-02T04-11-44Z: Determine Helmchart Export Path
        Step: 2024-08-02T04-11-44Z: Pulling HelmChart: mcr.microsoft.com/azurearck8s/batch1/stable/azure-arc-k8sagents, Version: 1.18.2
        "Successsfully enabled features: ['cluster-connect', 'custom-locations'] for the Connected Cluster arctest002Arc"

8. Deploy KeyVault Extetion via ARC

    ```bash
    az aks enable-addons --addons azure-keyvault-secrets-provider --name arctest003aks --resource-group arctest003
    ```

9. Deploy Event Grid Extension via ARC

    ```bash
    az extension add --upgrade --name azure-iot-ops
    az iot ops init --subscription 5f5dd16b-0879-4c86-884f-30347411b95f -g arctest003 --cluster arctest003aks --kv-id /subscriptions/5f5dd16b-0879-4c86-884f-30347411b95f/resourceGroups/arctest003/providers/Microsoft.KeyVault/vaults/arctest003kv --custom-location arctest003aks-cl --target arctest003aks-target --include-dp --dp-instance arctest003aks-processor --simulate-plc --mq-instance mq-instance--2003 --mq-mode auto --mq-mem-profile low
    ```

10. Deploy IoT Operations Extension via ARC

    ```bash
    az extension add --upgrade --name azure-iot-ops
    az iot ops init --subscription 5f5dd16b-0879-4c86-884f-30347411b95f -g arctest003 --cluster arctest003aks --kv-id /subscriptions/5f5dd16b-0879-4c86-884f-30347411b95f/resourceGroups/arctest003/providers/Microsoft.KeyVault/vaults/arctest003kv --custom-location arctest003aks-cl --target arctest003aks-target --include-dp --dp-instance arctest003aks-processor --simulate-plc --mq-instance mq-instance--2003 --mq-mode auto --mq-mem-profile low
    ```

11. [Goto IoT Operation Experience Portal](https://iotoperations.azure.com/)

## GitOps

Deployment of AIO through GitOps, there are some additional steps you will need to take to set up the fork.

1. Set the `AZURE_CREDENTIALS` repository secret. (Above)

    1. Create a Service Principal resource for the repository to use when performing GitHub actions.

        ```bash
        # If you haven't upgraded your Azure CLI lately, run the following.
        az upgrade

        # Create a Service Principal to perform operations on the provided subscription.
        az ad sp create-for-rbac --name $SP_NAME --role owner --scopes /subscriptions/$SUBSCRIPTION_ID --json-auth
        ```

    2. Copy the JSON output from the Service Principal creation command and paste into a repository secret named `AZURE_CREDENTIALS`
        in your fork. Repository secrets can be found under **Settings** > **Secrets and
       variables** > **Actions**. To learn more, see [creating secrets for a repository](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository).

2. Set the `sshRSAPublicKey` repository secret or use the gitops workflow to generate one automaticlly.

    1. SSH public key.

    ```bash
    ssh-keygen -m PEM -t rsa -b 4096
    ```

3. Enable GitHub actions on the fork.

    1. On the forked repo, select **Actions** and select **I understand my workflows, go ahead and enable them.**

## Available Parameters

Various parameters can be specified when deploying AIO. The below table describes these parameters. For an example parameter file, see `environments/example.parameters.json`.

| **Parameter** | **Requirement** | **Type** | **Description** |
| ------------- |--|------------|-------------- |
| clusterName   | ***[Required]*** | `string` | The Arc-enabled cluster resource in Azure.  |
| clusterLocation | *[Optional]* | `string` |If the cluster resource's location is different than its resource group's location, the cluster location will need to be specified. Otherwise, this parameter will default to the location of the resource group.  |
| location      | *[Optional]*  | `string` | If the resource group's location is not a supported AIO region, this parameter can be used to override the location of the AIO resources. |
| simulatePLC | *[Optional]*  | `boolean` | Flag to enable a simulated PLC. The default is false. |
| opcuaDiscoveryEndpoint | *[Optional]*  | `string` | The OPC UA Discovery Endpoint used by Akri. The default is opc.tcp://<NOT_SET>:<NOT_SET>. |
| deployResourceSyncRules | *[Optional]* | `boolean` | Flag to deploy the default resource sync rules for the AIO arc extensions. The default is `true`.|

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is
subject to and must follow [Microsoft’s Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this
project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those
third-party’s policies.

## Terms of Use

Please see [Supplemental Terms of Use for Microsoft Azure Previews.](https://azure.microsoft.com/en-us/support/legal/preview-supplemental-terms/)

## Contributing

Please see [Contributing.](https://github.com/Azure/azure-iot-operations/blob/main/CONTRIBUTING.md)

## Reporting Security Issues

Please see [Security.](https://github.com/Azure/azure-iot-operations/blob/main/SECURITY.md)

## Help and Guidance

1. [Deploy apps to Azure-Arc enabled Kubernetes cluster using 'Cluster Connect' and 'GitHub Actions'](https://techcommunity.microsoft.com/t5/azure-arc-blog/deploy-apps-to-azure-arc-enabled-kubernetes-cluster-using/ba-p/3286541)
2. [aksbicep](https://github.com/jaydestro/aksbicep/tree/main)
3. [Quickstart: Deploy an Azure Kubernetes Service (AKS) cluster using Bicep](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-bicep?tabs=azure-cli)
4. [Create an Azure Kubernetes Service (AKS) cluster with API Server VNET Integration using Bicep](https://github.com/Azure-Samples/aks-api-server-vnet-integration-bicep/tree/main)
5. [Private AKS with bicep](https://github.com/vakappas/private-aks-bicep/blob/main/README.md)
6. [mq-onelake-upload](https://github.com/Azure-Samples/explore-iot-operations/blob/main/tutorials/mq-onelake-upload/deployBaseResources.bicep)
7. [azure-edge-extensions-aio-dp-jumpstart](https://github.com/Azure-Samples/azure-edge-extensions-aio-dp-jumpstart/tree/main)
8. [Local K2d in K3s on docker](https://www.suse.com/c/introduction-k3d-run-k3s-docker-src/)
9. [Azure iot sample opc ua server](https://learn.microsoft.com/en-us/samples/azure-samples/iot-edge-opc-plc/azure-iot-sample-opc-ua-server/)
10. [Configure the simulator](https://learn.microsoft.com/en-au/azure/iot-operations/get-started/quickstart-add-assets)

## Troubleshoot

1. How Connecting a cluster should look

    ```bash
    Requesting a Cloud Shell.Succeeded. 
    Connecting terminal...

    Welcome to Azure Cloud Shell

    Type "az" to use Azure CLI
    Type "help" to learn about Cloud Shell

    Your Cloud Shell session will be ephemeral so no files or system changes will persist beyond your current session.
    elliot [ ~ ]$ az account set --subscription 5f5dd16b-0879-4c86-884f-30347411b95f
    elliot [ ~ ]$ az aks get-credentials --resource-group arctest003 --name arctest003aks --overwrite-existing
    Merged "arctest003aks" as current context in /home/elliot/.kube/config
    elliot [ ~ ]$ az connectedk8s connect --name "arctest003aks" --resource-group "arctest003" --location "eastus" --correlation-id "c18ab9d0-685e-48e7-ab55-12588447b0ed" --tags "Datacenter City StateOrDistrict CountryOrRegion"
    The command requires the extension connectedk8s. Do you want to install it now? The command will continue to run after the extension is installed. (Y/n): y
    Run 'az config set extension.use_dynamic_install=yes_without_prompt' to allow installing extensions without prompt.
    Default enabled including preview versions for extension installation now. Disabled in future release. Use '--allow-preview true' to enable it specifically if needed. Use '--allow-preview false' to install stable version only. 
    This operation might take a while...

    Step: 2024-08-01T02-05-29Z: Validating custom access token
    Step: 2024-08-01T02-05-29Z: Checking Provider Registrations
    Step: 2024-08-01T02-05-30Z: Setting KubeConfig
    Step: 2024-08-01T02-05-30Z: Escape Proxy Settings, if passed in
    Step: 2024-08-01T02-05-30Z: Checking Connectivity to Cluster
    Step: 2024-08-01T02-05-31Z: Do node validations
    Step: 2024-08-01T02-05-33Z: Install Kubectl client if it does not exist
    Downloading kubectl client for first time. This can take few minutes...
    To check existing issues, please visit: https://github.com/Azure/azure-cli/issues


    Step: 2024-08-01T02-05-46Z: Install Helm client if it does not exist
    Downloading helm client for first time. This can take few minutes...
    Step: 2024-08-01T02-05-57Z: Starting Pre-onboarding-check
    Step: 2024-08-01T02-05-57Z: Creating folder for Cluster Diagnostic Checks Logs
    Step: 2024-08-01T02-05-57Z: Get namespace of release: cluster-diagnostic-checks
    Step: 2024-08-01T02-05-58Z: Determine Helmchart Export Path
    Step: 2024-08-01T02-05-58Z: Pulling HelmChart: mcr.microsoft.com/azurearck8s/helmchart/stable/clusterdiagnosticchecks, Version: 0.2.2
    Step: 2024-08-01T02-05-59Z: Chart path for Cluster Diagnostic Checks Job: /home/elliot/.azure/PreOnboardingChecksCharts/clusterdiagnosticchecks
    Step: 2024-08-01T02-05-59Z: Creating Cluster Diagnostic Checks job
    Step: 2024-08-01T02-06-13Z: The required pre-checks for onboarding have succeeded.
    Step: 2024-08-01T02-06-13Z: Checking if user can create ClusterRoleBindings
    Step: 2024-08-01T02-06-14Z: Determining Cluster Distribution and Infrastructure
    Connecting an Azure Kubernetes Service (AKS) cluster to Azure Arc is only required for running Arc enabled services like App Services and Data Services on the cluster. Other features like Azure Monitor and Azure Defender are natively available on AKS. Learn more at https://go.microsoft.com/fwlink/?linkid=2144200.
    Step: 2024-08-01T02-06-14Z: Checking Connect RP is available in the Location passed in.
    Step: 2024-08-01T02-06-14Z: Check if an earlier azure-arc release exists
    Step: 2024-08-01T02-06-14Z: Get namespace of release: azure-arc
    Step: 2024-08-01T02-06-16Z: Deleting Arc CRDs
    Step: 2024-08-01T02-06-33Z: Check if ResourceGroup exists.  Try to create if it doesn't
    Step: 2024-08-01T02-06-33Z: Getting HelmPackagePath from Arc DataPlane
    Step: 2024-08-01T02-06-34Z: Determine Helmchart Export Path
    Step: 2024-08-01T02-06-34Z: Pulling HelmChart: mcr.microsoft.com/azurearck8s/batch1/stable/azure-arc-k8sagents, Version: 1.18.2
    Step: 2024-08-01T02-06-34Z: Generating Public-Private Key pair
    Step: 2024-08-01T02-06-48Z: Generating ARM Request Payload
    Step: 2024-08-01T02-06-48Z: Azure resource provisioning has begun.
    Step: 2024-08-01T02-08-29Z: Azure resource provisioning has finished.
    Step: 2024-08-01T02-08-29Z: Checking Microsoft.ExtendedLocation RP Registration state for this Subscription, and get OID, if registered 
    Step: 2024-08-01T02-08-32Z: Starting to install Azure arc agents on the Kubernetes cluster.
    Step: 2024-08-01T02-10-02Z: Helm install of Azure arc agents Release ended.
    {
    "agentPublicKeyCertificate": "MIICCgKCAgEAspFeAWJeuONGennjH4lPVxLvmQrEbA3eFArUPF+UxIlSAlIw0mGvukRaM85j9OyGomnFaFgQogLG5nwNQVzNFsn3k/5Crxm6I6qJEJiaOrwPCqbVADirYJJa1hzFBSCeubpeYx4YlF5LEJQCKd6/qS/QRgq9NrOjdICB+nfD27de9DJ6O0de7cnitn3xShdPTYelKOddk9A/ZiiwdZg74spoIl/eA00QN8FM7mfHo3saiOYbmm+jYehmEsD9aXqG0JyG4xBscU0YMRsV0wbH5zCwcbxgiHNGLXZulHpaY1rRTGnNt4i/5AWFmzhwfCXqcRIYLJ81/seFz3XwFynly6DxWc/glKVdxx4EvoUh2EohKC/MK2946SECD4XsAP6MVuuBxy8vlPHQQTZqQsBQUTZ89vS0zV2XhXPF/oNsPhmgurvPitb6AzUDLiNKsBZyDQ6WLv0n89kEHtK0+d9QrW4b1aA1+YOy/HTrCMpnZD1LAgdFSaW+4oic5iOZZarhsiMPZGywJ7++dj/6zdEZs4otJqIu0zRf3tvLf2jZIgswuvqLX6Izs8NqCBq37nS3UWjODo9Ig0RlWNqrg2Dz5TK6OOXPoGhv4oB+G6WQKPT3xpY2xRRcNCP6nQgD7tNBScfYokrdifLvaxnL5NNqQ0JOFdCRIimclm9d9Uy5vMcCAwEAAQ==",
    "agentVersion": null,
    "connectivityStatus": "Connecting",
    "distribution": "aks",
    "id": "/subscriptions/5f5dd16b-0879-4c86-884f-30347411b95f/resourceGroups/arctest003/providers/Microsoft.Kubernetes/connectedClusters/arctest003aks",
    "identity": {
        "principalId": "de9459e4-6068-412d-8020-f357b2e68c3f",
        "tenantId": "1b4cd3e4-a68e-41ec-bf16-08766eed1e94",
        "type": "SystemAssigned"
    },
    "infrastructure": "azure",
    "kubernetesVersion": null,
    "lastConnectivityTime": null,
    "location": "eastus",
    "managedIdentityCertificateExpirationTime": null,
    "name": "arctest003aks",
    "offering": null,
    "provisioningState": "Succeeded",
    "resourceGroup": "arctest003",
    "systemData": {
        "createdAt": "2024-08-01T02:06:51.426587+00:00",
        "createdBy": "elliot.wood@lab3.com.au",
        "createdByType": "User",
        "lastModifiedAt": "2024-08-01T02:06:51.426587+00:00",
        "lastModifiedBy": "elliot.wood@lab3.com.au",
        "lastModifiedByType": "User"
    },
    "tags": {
        "Datacenter City StateOrDistrict CountryOrRegion": ""
    },
    "totalCoreCount": null,
    "totalNodeCount": null,
    "type": "microsoft.kubernetes/connectedclusters"
    }

    ```

2. User or App doest not have Keyvault List Permission

    ```bash
    az iot ops init --subscription 5f5dd16b-0879-4c86-884f-30347411b95f -g arctest003 --cluster arctest003aks --kv-id /subscriptions/5f5dd16b-0879-4c86-884f-30347411b95f/resourceGroups/arctest003/providers/Microsoft.KeyVault/vaults/arctest003kv --custom-location arctest003aks-cl --target arctest003aks-target --include-dp --dp-instance arctest003aks-processor --simulate-plc --mq-instance mq-instance--2003 --mq-mode auto --mq-mem-profile low
    Command group 'iot ops' is in preview and under development. Reference and support levels: https://aka.ms/CLI_refstatus
                                                                                                                                                                                                                                    
    Azure IoT Operations init                                                                                                                                                                                                          
    Workflow Id: 8428dd6619174e0dba804a6634440fbf                                                                                                                                                                                      
                                                                                                                                                                                                                                    
    Pre-Flight                                                                                                                                                                                                                      
        ✔ Ensure registered IoT Ops resource providers                                                                                                                                                                                
        ✔ Enumerate pre-flight checks                                                                                                                                                                                                 
        ✔ Verify What-If deployment                                                                                                                                                                                                   
    -> Key Vault CSI Driver                                                                                                                                                                                                            
        ✔ Verify Key Vault 'arctest003kv' permission model                                                                                                                                                                            
        ✔ Created app 'eb0d691a-4971-48db-9d36-35e5d9ca775e'                                                                                                                                                                          
        ✔ Configure access policy                                                                                                                                                                                                     
        * Ensure default SPC secret name 'azure-iot-operations'                                                                                                                                                                       
        - Test SP access                                                                                                                                                                                                              
        - Deploy driver to cluster 'v1.5.3'                                                                                                                                                                                           
        - Configure driver                                                                                                                                                                                                            
    TLS                                                                                                                                                                                                                             
        - Generate test CA using 'secp256r1' valid for '365' days                                                                                                                                                                     
        - Configure cluster for tls                                                                                                                                                                                                   
    Deploy IoT Operations - v0.5.1-preview                                                                                                                                                                                          
                                                                                                                                                                                                                                    
    ⠸ Done. ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Elapsed: 0:01:50                                                                                                                                                                
                                                                                                                                                                                                                                    
    Forbidden({"error":{"code":"Forbidden","message":"The user, group or application 'appid=b677c290-cf4b-4a8e-a60e-91ba650a4abe;oid=bb6c54df-d80b-4d79-877c-57a972e95cb4;numgroups=1;iss=https://sts.windows.net/1b4cd3e4-a68e-41ec-bf16-08766eed1e94/' does not have secrets list permission on key vault 'arctest003kv;location=eastus'. For help resolving this issue, please see https://go.microsoft.com/fwlink/?linkid=2125287","innererror":{"code":"AccessDenied"}}})
    ```

    1. Goto Azure portal - find the keyvault, click Access polices, then create access policy - https://learn.microsoft.com/en-us/azure/key-vault/general/assign-access-policy?tabs=azure-portal 
    2. Choose User or App - in  my case its was my OID for my user account, then on application skip.
    3. Save and retry command.

        ```bash
        az iot ops init --subscription 5f5dd16b-0879-4c86-884f-30347411b95f -g arctest003 --cluster arctest003aks --kv-id /subscriptions/5f5dd16b-0879-4c86-884f-30347411b95f/resourceGroups/arctest003/providers/Microsoft.KeyVault/vaults/arctest003kv --custom-location arctest003aks-cl --target arctest003aks-target --include-dp --dp-instance arctest003aks-processor --simulate-plc --mq-instance mq-instance--2003 --mq-mode auto --mq-mem-profile low
        Command group 'iot ops' is in preview and under development. Reference and support levels: https://aka.ms/CLI_refstatus
                                                                                                                                                                                                                                        
        Azure IoT Operations init                                                                                                                                                                                                          
        Workflow Id: 4daded8a40bb4a418fbaa61d944e7b8e                                                                                                                                                                                      
                                                                                                                                                                                                                                        
        Pre-Flight                                                                                                                                                                                                                      
            ✔ Ensure registered IoT Ops resource providers                                                                                                                                                                                
            ✔ Enumerate pre-flight checks                                                                                                                                                                                                 
            ✔ Verify What-If deployment                                                                                                                                                                                                   
        -> Key Vault CSI Driver                                                                                                                                                                                                            
            ✔ Verify Key Vault 'arctest003kv' permission model                                                                                                                                                                            
            ✔ Created app '83a8afed-af31-44a0-a6e7-f64854e779da'                                                                                                                                                                          
            ✔ Configure access policy                                                                                                                                                                                                     
            ✔ Ensure default SPC secret name 'azure-iot-operations'                                                                                                                                                                       
            ✔ Test SP access                                                                                                                                                                                                              
            * Deploy driver to cluster 'v1.5.3'                                                                                                                                                                                           
            - Configure driver                                                                                                                                                                                                            
        TLS                                                                                                                                                                                                                             
            - Generate test CA using 'secp256r1' valid for '365' days                                                                                                                                                                     
            - Configure cluster for tls                                                                                                                                                                                                   
        Deploy IoT Operations - v0.5.1-preview                                                                                                                                                                                          
                                                                                                                                                                                                                                        
        ⠦ Work. ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   Elapsed: 0:17:51
        ```

3. Running K3s in Docker then register in arc

    1. You man need to first install prereqs like cli onto host machine (im using windows), for linux prepend sudo to the commands)

        ```bash
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        az extension add --name connectedk8s
        az login --use-device-code
        ```

    2. Register providers

        ```bash
        az provider register --namespace Microsoft.Kubernetes
        az provider register --namespace Microsoft.KubernetesConfiguration
        az provider register --namespace Microsoft.ExtendedLocation

        az provider show -n Microsoft.Kubernetes -o table
        az provider show -n Microsoft.KubernetesConfiguration -o table
        az provider show -n Microsoft.ExtendedLocation -o table
        ```

    3. There are several ways to run K3s in Docker:

        To use Docker, rancher/k3s images are also available to run the K3s server and agent. Using the docker run command:

        ```bash
        #docker run --privileged --name k3s-server-1 --hostname k3s-server-1 -p 6443:6443 -d rancher/k3s:v1.24.10-k3s1 server
        docker run -d --name k3s-server-1 --privileged -v /var/lib/kubelet:/var/lib/kubelet:shared -v /var/run:/var/run -p 6443:6443 rancher/k3s:v1.24.10-k3s1 server
        ```

        You must specify a valid K3s version as the tag; the latest tag is not maintained.
        Docker images do not allow a + sign in tags, use a - in the tag instead.

    4. Once K3s is up and running, you can copy the admin kubeconfig out of the Docker container for use:

        ```bash
        docker cp k3s-server-1:/etc/rancher/k3s/k3s.yaml .kube/config
        ```

    5. From host machine run

        ```bash
        az connectedk8s connect --name arctest002Arc --resource-group arctest002 --location eastus 
        ```

        Outputs:

        ```bash
        This operation might take a while...

        The required pre-checks for onboarding have succeeded.
        Azure resource provisioning has begun.
        Azure resource provisioning has finished.
        Starting to install Azure arc agents on the Kubernetes cluster.
        {
        "agentPublicKeyCertificate": "MIICCgKCAgEAriglHP4WUqUBpG6YYcuj0cVnAaZiIwxdPRFDyGxSPccZOdCT0Mp7MAICsEcANOHcJDikIzSlzdAQ+jEaXKSmmHU/3xG7LqBIRXl1xE+IHMXk96tLLhvDPzcdGkYOWbjNkY6mXU+x9zKmq4EU+8K5dqkjwxmRDokqIQivFZ6K6hrf1eriQFThs7aZcaRu4i7Clp22UAYztWF/927L4my3DlSSdQijHt0tVLIlMMnRh1vhNEYFMK2+Zaj6lHG4il6HDJyyvXV5iihnnxxKiIl1nVwGH3xJTgJW+5KSd5ahv2/z54a/Eq51Wk+md238L4s+YP6Eoy0YT97voLE8PPRVu13nNyF40DwEFrQIzijeb8p1G9E5lAGdVuKIqLThEoN5JT+1N2fnmhISb9owcx2CIzKI6PPpAMJYGAowm1FQ1htG8fo9O5UPXX6GOXhiE7Xhk9Ukxvp3y8uc2VtiNYGWbW+lg2Ua1T3oZJvWLYMQcdLHXbZqZpkNr2la/V2YPmJ2rNN238jaAVXvyQoRF8TNBSifWVCPYD6dwZ1ML9Bdm6E4ibnEMhCcPp882DaQMm8hXiPahDfjvAxXR3qF/hSeEBTsqufnrXcbGp1TWb2GkEkB5JHoSNjE2ihjiu4Fe+JR78gXbmuSjTNBjC7KuIx9fH36mIvN+OwTSMaD94Rbu7MCAwEAAQ==",
        "agentVersion": null,
        "connectivityStatus": "Connecting",
        "distribution": "k3s",
        "id": "/subscriptions/5f5dd16b-0879-4c86-884f-30347411b95f/resourceGroups/arctest002/providers/Microsoft.Kubernetes/connectedClusters/arctest002Arc",
        "identity": {
            "principalId": "d9bc9fb7-1035-4478-a553-02bfb4f7d615",
            "tenantId": "1b4cd3e4-a68e-41ec-bf16-08766eed1e94",
            "type": "SystemAssigned"
        },
        "infrastructure": "generic",
        "kubernetesVersion": null,
        "lastConnectivityTime": null,
        "location": "eastus",
        "managedIdentityCertificateExpirationTime": null,
        "name": "arctest002Arc",
        "offering": null,
        "provisioningState": "Succeeded",
        "resourceGroup": "arctest002",
        "systemData": {
            "createdAt": "2024-08-01T03:30:35.836411+00:00",
            "createdBy": "elliot.wood@lab3.com.au",
            "createdByType": "User",
            "lastModifiedAt": "2024-08-01T03:30:35.836411+00:00",
            "lastModifiedBy": "elliot.wood@lab3.com.au",
            "lastModifiedByType": "User"
        },
        "tags": {},
        "totalCoreCount": null,
        "totalNodeCount": null,
        "type": "microsoft.kubernetes/connectedclusters"
        }
        ```

    6. Verify its connected

        ```bash
        az connectedk8s list --resource-group arctest002 --output table
        ```

        Outputs:

        ```bash
        Name           Location    ResourceGroup
        -------------  ----------  ---------------
        arctest002Arc  eastus      arctest002
        ```

4. Checking IoT Operations

    ```bash
        elliot [ ~ ]$ az iot ops check
        Command group 'iot ops' is in preview and under development. Reference and support levels: https://aka.ms/CLI_refstatus

        ────────────────────────────── Evaluation for {mq} service deployment ──────────────────────────────

        Post deployment checks ─────────────────────────────────────────────────────────────────────────────

            ✔ Enumerate MQ API resources                                                                    
                mq.iotoperations.azure.com/v1beta1 API resources                                            
                    DataLakeConnectorTopicMap                                                               
                    KafkaConnector                                                                          
                    MqttBridgeConnector                                                                     
                    IoTHubConnector                                                                         
                    DataLakeConnector                                                                       
                    Broker                                                                                  
                    MqttBridgeTopicMap                                                                      
                    BrokerAuthorization                                                                     
                    DiagnosticService                                                                       
                    BrokerListener                                                                          
                    BrokerAuthentication                                                                    
                    IoTHubConnectorRoutesMap                                                                
                    KafkaConnectorTopicMap                                                                  

            ✔ Evaluate MQ brokers                                                                           
                                                                                                            
            ✔ MQ Brokers in namespace {azure-iot-operations}                                              
                - Expecting 1 broker resource per namespace. Detected 1.                                    
                                                                                                            
                - Broker {broker} mode auto.                                                                
                    Status {Running}. All back and frontend replicas are running.                           
                                                                                                            
                Runtime Health                                                                              
                    Pod {aio-mq-diagnostics-probe-0} in phase {Running}.                                    
                    Pod {aio-mq-dmqtt-frontend-0} in phase {Running}.                                       
                    Pod {aio-mq-dmqtt-frontend-1} in phase {Running}.                                       
                    Pod {aio-mq-dmqtt-backend-1-0} in phase {Running}.                                      
                    Pod {aio-mq-dmqtt-backend-1-1} in phase {Running}.                                      
                    Pod {aio-mq-dmqtt-backend-2-0} in phase {Running}.                                      
                    Pod {aio-mq-dmqtt-backend-2-1} in phase {Running}.                                      
                    Pod {aio-mq-dmqtt-authentication-0} in phase {Running}.                                 
                    Pod {aio-mq-dmqtt-health-manager-0} in phase {Running}.                                 

            ✔ Evaluate MQ broker listeners                                                                  
                                                                                                            
            ✔ Broker Listeners in namespace {azure-iot-operations}                                        
                - Expecting >=1 broker listeners per namespace. Detected 1.                                 
                                                                                                            
                - Broker Listener {listener}. Valid broker reference {broker}.                              
                                                                                                            
            ✔ Service {aio-mq-dmqtt-frontend} of type clusterIp                                           

            ✔ Evaluate MQ Diagnostics Service                                                               
                                                                                                            
            ✔ Diagnostic Service Resources in namespace {azure-iot-operations}                            
                - Expecting 1 diagnostics service resource per namespace. Detected 1.                       
                                                                                                            
                - Diagnostic service resource {diagnostics}.                                                
                                                                                                            
            ✔ Service Status                                                                              
                    Service {aio-mq-diagnostics-service} detected.                                          
                    Pod {aio-mq-diagnostics-service-f8fb947dc-dbsb6} in phase {Running}.                    

            🔨 Evaluate MQTT Bridge Connectors                                                              
                No MQTT Bridge Connector resources detected                                                 

            🔨 Evaluate Data Lake Connectors                                                                
                No Data Lake Connector resources detected                                                   

            🔨 Evaluate Kafka Connectors                                                                    
                No Kafka Connector resources detected                                                       


        ╭─────── Check Summary ───────╮
        │ 17 check(s) succeeded.      │
        │ 0 check(s) raised warnings. │
        │ 0 check(s) raised errors.   │
        │ 3 check(s) were skipped.    │
        ╰─────────────────────────────╯
    ```

Follow these steps in the order to start routing events using Event Grid on Kubernetes.

1. [Connect your cluster to Azure Arc](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster).
    See Above

2. [Install an Event Grid extension](https://learn.microsoft.com/en-us/azure/event-grid/kubernetes/install-k8s-extension), which is the actual resource that deploys Event Grid to a Kubernetes cluster. To learn more about the extension, see [Event Grid Extension](https://learn.microsoft.com/en-us/azure/event-grid/kubernetes/install-k8s-extension#event-grid-extension) section to learn more.

    1. Get storage info

        1. using docker k3s

            - Make sure to apply these from host machine for the docker hosted kube cluster

                ```bash
                kubectl apply -f pvc.yaml
                kubectl apply -f pod.yaml
                ```

                ```yaml
                    ---pvc.yaml---
                    apiVersion: v1
                    kind: PersistentVolumeClaim
                    metadata:
                    name: my-pvc
                    spec:
                    accessModes:
                        - ReadWriteOnce
                    resources:
                        requests:
                        storage: 1Gi
                    ---pod.yaml---
                    apiVersion: v1
                    kind: Pod
                    metadata:
                    name: my-pod
                    spec:
                    containers:
                    - name: my-container
                        image: busybox
                        command: ["sleep", "3600"]
                        volumeMounts:
                        - mountPath: "/data"
                        name: my-volume
                    volumes:
                    - name: my-volume
                        persistentVolumeClaim:
                        claimName: my-pvc
                    ---
                ```

            - K3s typically installs with a default storage class configured.
                
                When you install K3s, it sets up a simple host-path based storage class that can be used for provisioning persistent volumes (PVs) in a single-node cluster or for simple use cases in multi-node clusters.

                You can check the default storage class in your K3s cluster with the following command:

                ```kubectl get storageclass```                You should see an output similar to:

                | NAME                  | PROVISIONER           | RECLAIMPOLICY | VOLUMEBINDINGMODE | ALLOWVOLUMEEXPANSION | AGE  |
                |-----------------------|------------------------|--------------|-------------------|----------------------|------|
                | local-path (default)  | rancher.io/local-path  | Delete       | Immediate         | false                |      |

        2. Using aks

            ```kubectl get storageclass```            You should see an output similar to:

            | NAME                  | PROVISIONER          | RECLAIMPOLICY | VOLUMEBINDINGMODE       | ALLOWVOLUMEEXPANSION | AGE  |
            |-----------------------|-----------------------|--------------|-------------------------|----------------------|------|
            | azurefile             | file.csi.azure.com    | Delete       | Immediate               | true                 | 5d5h |
            | azurefile-csi         | file.csi.azure.com    | Delete       | Immediate               | true                 | 5d5h |
            | azurefile-csi-premium | file.csi.azure.com    | Delete       | Immediate               | true                 | 5d5h |
            | azurefile-premium     | file.csi.azure.com    | Delete       | Immediate               | true                 | 5d5h |
            | default (default)     | disk.csi.azure.com    | Delete       | WaitForFirstConsumer    | true                 | 5d5h |
            | managed               | disk.csi.azure.com    | Delete       | WaitForFirstConsumer    | true                 | 5d5h |
            | managed-csi           | disk.csi.azure.com    | Delete       | WaitForFirstConsumer    | true                 | 5d5h |
            | managed-csi-premium   | disk.csi.azure.com    | Delete       | WaitForFirstConsumer    | true                 | 5d5h |
            | managed-premium       | disk.csi.azure.com    | Delete       | WaitForFirstConsumer    | true                 | 5d5h |

        3. Create event grid extention (UI)

            - name eventgrid-etx
            - Namespace eventgrid-system
            - storage class
                1. specified k3s built in storage local-path
                2. or azurefile for aks
            - Cluster extension details:

            | Key                                                        | Value          |
            |------------------------------------------------------------|----------------|
            | Microsoft.CustomLocation.ServiceAccount                   | eventgrid-operator |
            | eventgridbroker.service.serviceType                        | ClusterIP       |
            | eventgridbroker.dataStorage.storageClassName                | local-path      |
            | eventgridbroker.diagnostics.metrics.reporterType            | none            |
            | eventgridbroker.service.supportedProtocols[0]               | http            |
            | eventgridbroker.dataStorage.size                            | 1Gi             |
            | eventgridbroker.resources.limits.memory                     | 1Gi             |
            | eventgridbroker.resources.requests.memory                   | 200Mi           |


3. [Create a custom location](https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/custom-locations). A custom location represents a namespace in the cluster and it's the place where topics and event subscriptions are deployed.

    1. Add Arc-enabled services

        Add eventgrid-etx | microsoft.eventgrid

4. [Create a topic and one or more event subscriptions](https://learn.microsoft.com/en-us/azure/event-grid/kubernetes/create-topic-subscription).

    | Name | Value |
    |----------------------------------------------------|---------------------------------------------|
    | Name                                               | arctest002-telemetry / arctest003-telemetry |
    | Subscription                                       | SensorMine-Development                      |
    | Resource group                                     | arctest002 / arctest003                     |
    | Location                                           | ewhouse / arctest003aks-cl (or the name of your custom location above) |
    | Networking                                         | Connectivity method                         |
    | Public access                                      | Schema                                      |
    | Event Schema                                       | Cloud Event Schema v1.0                     |
    | Identity                                           | Enable system assigned identity             |
    | Disabled                                           | Enable user assigned identity               |
    | Disabled                                           | Transport layer security                    |
    | Minimum TLS version                                | 1.2                                         |

5. [Publish events](https://learn.microsoft.com/en-us/azure/event-grid/kubernetes/create-topic-subscription)