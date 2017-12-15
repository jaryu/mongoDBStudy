#!/bin/bash
az group create --name minschoMongoDBRG01 --location koreacentral
az group deployment create --name networkForMongoDBDeployment --resource-group minschoNetRG \
--template-file 00.mongoNet.json \
--parameters vnet_name=minschoVnet01 \
--parameters subnet_name=testSubnet01 \
--parameters publicip_name=mongoDBSingleNodeIP \
--parameters dnsPrefix=mongodbtest01 \
--parameters nic_name=mongodbTestNic01


az group deployment create --name createVM --resource-group minschoMongoDBRG01 --template-file 02.vm.json \
--parameters vm_name=mongoTestVM01 \
--parameters adminUserId=minsoojo \
--parameters nic_name=mongodbTestNic01 \
--parameters dataDisk_name01=mongodbDataDisk01 \
--parameters dataDisk_name02=mongodbDataDisk02

# disk 두 개 만듬
az group deployment create --name createDataDisk --resource-group minschoMongoDBRG01 --template-file 01.dataDisk.json \
--parameters dataDisk_name=mongodbDataDisk01
az group deployment create --name createDataDisk --resource-group minschoMongoDBRG01 --template-file 01.dataDisk.json \
--parameters dataDisk_name=mongodbDataDisk02
# data disk attach
az vm disk attach --vm-name mongoTestVM01 --disk mongodbDataDisk01 --lun 0 --resource-group minschoMongoDBRG01
az vm disk attach --vm-name mongoTestVM01 --disk mongodbDataDisk02 --lun 1 --resource-group minschoMongoDBRG01

#disk lun 확인
az vm show --resource-group minschoMongoDBRG01 --name mongoTestVM01 | jq -r .storageProfile.dataDisks
az vm show --resource-group minschoMongoDBRG01 --name mongoTestVM01 | jq -r .storageProfile.dataDisks[].lun