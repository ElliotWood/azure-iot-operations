# azure-iot-operations

## Overview

This repo contains the deployment definition of Azure IoT Operations (AIO) and allows for
AIO to be deployed to an Arc-enabled K8s cluster. This repository does not encourage pull requests, as the repo is
meant for publicly sharing the releases of AIO and not shared development of AIO.

Please see the [Azure IoT Operations documentation](https://aka.ms/AIOdocs) for more information. To learn how to
deploy AIO using GitOps, see the [Deploy to cluster documentation](https://learn.microsoft.com/en-us/azure/iot-operations/deploy-iot-ops/howto-deploy-iot-operations?tabs=github#deploy-extensions).

# Prereq

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