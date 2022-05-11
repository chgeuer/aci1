// DeploymentScriptOperationFailed
// 
// The client '8d0ee805-ab3a-4152-8bc4-a1f179eda399' with object id '8d0ee805-ab3a-4152-8bc4-a1f179eda399' 
// does not have authorization to perform action 'Microsoft.Storage/storageAccounts/write' over scope 
// '/subscriptions/.../resourceGroups/.../providers/Microsoft.Storage/storageAccounts/b4fh3gvkqrdlsazscripts' 
// or the scope is invalid. 
// If access was recently granted, please refresh your credentials.

param location string = resourceGroup().location

var roles = {
  reader: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'identity'
  location: location
}

resource managedAppRGPermission 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('vm-can-read-resource-group-to-determine-stuff', resourceGroup().id)
  scope: resourceGroup()
  properties: {
    principalType: 'ServicePrincipal'
    principalId: reference(identity.id, '2018-11-30').principalId
    // Want to give only Reader priviliges, so that the managed identity can access the RG in the bash script
    // But then it doesn't have access to the dynamically created storage account.
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roles.contributor)
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2019-10-01-preview' = {
  name: 'deploymentScript'
  location: location
  dependsOn: [
    managedAppRGPermission
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.36.0'
    timeout: 'PT30M'
    retentionInterval: 'P1D'
    cleanupPreference: 'OnExpiration'
    environmentVariables: [
      {
        name: 'resourceGroupName'
        value: resourceGroup().name
      }
      {
        name: 'subscriptionId'
        value: subscription().subscriptionId
      }
    ]
    primaryScriptUri: uri(deployment().properties.templateLink.uri, 'script.sh')
  }
}

output o object = reference(deploymentScript.id, '2019-10-01-preview', 'Full')
output p object = deploymentScript.properties
output o2 object = reference(deploymentScript.name).outputs.rgjson
output locat string = reference(deploymentScript.name).outputs.rgjson.location
output o4 string = reference(deploymentScript.name).outputs.access_token
