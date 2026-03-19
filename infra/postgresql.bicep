param location string = resourceGroup().location
param serverName string = 'chainiq-postgres'
param adminLogin string
@secure()
param adminPassword string
param dbName string = 'chainiq'
param skuName string = 'Standard_B1ms'
param skuTier string = 'Burstable'

resource pgServer 'Microsoft.DBforPostgreSQL/flexibleServers@2023-06-01-preview' = {
  name: serverName
  location: location
  sku: { name: skuName, tier: skuTier }
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
    version: '16'
    storage: { storageSizeGB: 32 }
    backup: { backupRetentionDays: 7, geoRedundantBackup: 'Disabled' }
    network: { publicNetworkAccess: 'Enabled' }
    highAvailability: { mode: 'Disabled' }
  }
}

resource pgFirewallAllowAzure 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2023-06-01-preview' = {
  parent: pgServer
  name: 'AllowAllAzureServicesAndResources'
  properties: { startIpAddress: '0.0.0.0', endIpAddress: '0.0.0.0' }
}

resource pgDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2023-06-01-preview' = {
  parent: pgServer
  name: dbName
}

output connectionString string = 'postgresql://${adminLogin}:${adminPassword}@${pgServer.properties.fullyQualifiedDomainName}:5432/${dbName}?sslmode=require'
