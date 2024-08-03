targetScope = 'subscription'

param appName string = 'bcc24'
param envName string = 'bicep'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-bcc24-bicep'
  location: 'centralus'
}

module mySite 'mysite.bicep' = {
  scope: rg
  name: 'sitedeploy'
  params: {
    appName: appName  
    envName: envName
  }
}
