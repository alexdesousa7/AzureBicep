param environmentName string {
  allowed: [
    'prod'
    'dev'
  ]
}
var defaultLocation = resourceGroup().location

param storageAccountName string {
  minLength: 3
  maxLength: 24
}
var sku = environmentName == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

resource diagsAccount 'Microsoft.Storage/storageAccounts@2020-08-01-preview' = {
  name: storageAccountName
  location: defaultLocation
  sku: {
    name: sku
  }
  kind: 'Storage'
}

param vmOS string {
  default: '2019-Datacenter'
  allowed: [
    '2016-Datacenter'
    '2016-Datacenter-Server-Core'
    '2016-Datacenter-Server-Core-smalldisk'
    '2019-Datacenter'
    '2019-Datacenter-Server-Core'
    '2019-Datacenter-Server-Core-smalldisk'
  ]
}
param vmAdminPassword string {
  secure: true
  metadata: {
    description: 'password for the windows VM'
  }
}
param vmPrefix string {
  minLength: 1
  maxLength: 9
}
var vmName = '${vmPrefix}-${environmentName}'
var vmNicName = '${vmName}-nic'

resource vmNic 'Microsoft.Network/networkInterfaces@2017-06-01' = {
  name: vmNicName
  location: defaultLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/front'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vmDataDisk 'Microsoft.Compute/disks@2019-07-01' = {
  name: '${vmName}-vhd'
  location: defaultLocation
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
    diskSizeGB: 32
    creationData: {
      createOption: 'Empty'
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vmName
  location: defaultLocation
  properties: {
    osProfile: {
      computerName: vmName
      adminUsername: 'localadm'
      adminPassword: vmAdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_A0'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: vmOS
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          name: '${vmName}-vhd'
          createOption: 'Attach'
          caching: 'ReadOnly'
          lun: 0
          managedDisk: {
            id: vmDataDisk.id
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: vmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: diagsAccount.properties.primaryEndpoints.blob
      }
    }
  }
}

param vnetName string {
  metadata: {
    description: 'name of the Virtual network'
  }
}
var vnetConfig = {
  vnetprefix: '10.0.0.0/21'
  subnet: {
    name: 'front'
    addressPrefix: '10.0.0.0/24'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnetName
  location: defaultLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetConfig.vnetprefix
      ]
    }
    subnets: [
      {
        name: vnetConfig.subnet.name
        properties: {
          addressPrefix: vnetConfig.subnet.addressPrefix
        }
      }
    ]
  }
}