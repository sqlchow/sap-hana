# ![SAP Deployment Automation Framework](../assets/images/UnicornSAPBlack64x64.png)**SAP Deployment Automation Framework** #

# Deployment Scenarios #

The SAP Deployment Automation Framework support the following deployment models:

## **Scenario 1 - Greenfield using the deployer** ##

In this scenario all Azure artifacts will be created by the automation framework. The deployment includes two environments "MGMT" and "DEV". Both environments need a Service Principal registered in the deployer key vault.

This scenario contains the following deployments

- Deployer
- Library
- Workload
- System: SID X00, with 2 Application Servers, a highly available Central Services instance, a single webdispatcher using a single node HANA backend using SUSE 12 SP5

A sample configuration for this is available here:

| Component                | Template |
| :------------------------| :----------------------------------------------------------------------- |
| Deployer                 | [DEPLOYER/MGMT-WEEU-DEP00-INFRASTRUCTURE/MGMT-WEEU-DEP00-INFRASTRUCTURE.json](./WORKSPACES/DEPLOYER/MGMT-WEEU-DEP00-INFRASTRUCTURE/MGMT-WEEU-DEP00-INFRASTRUCTURE.json)
| Library                  | [LIBRARY/MGMT-WEEU-SAP_LIBRARY/MGMT-WEEU-SAP_LIBRARY.json](./WORKSPACES/LIBRARY/MGMT-WEEU-SAP_LIBRARY/MGMT-WEEU-SAP_LIBRARY.json)
| Workload                 | [LANDSCAPE/DEV-WEEU-SAP01-INFRASTRUCTURE/DEV-WEEU-SAP01-INFRASTRUCTURE.json](./WORKSPACES//LANDSCAPE/DEV-WEEU-SAP01-INFRASTRUCTURE/DEV-WEEU-SAP01-INFRASTRUCTURE.json)
| System                   | [SYSTEM/DEV-WEEU-SAP01-X00/DEV-WEEU-SAP01-X00.json](./WORKSPACES/SYSTEM/DEV-WEEU-SAP01-X00/DEV-WEEU-SAP01-X00.json)

<br>

From the cloned repository copy the following folders to your root folder (*Azure_SAP_Automated_Deployment/WORKSPACES*) for parameter files

- DEPLOYER/MGMT-WEEU-DEP00-INFRASTRUCTURE
- LIBRARY/MGMT-WEEU-SAP_LIBRARY
- LANDSCAPE/DEV-WEEU-SAP01-INFRASTRUCTURE
- SYSTEM/DEV-WEEU-SAP01-X00

The helper script below can be used to copy the pertinent folders.

```bash
    cd ~/Azure_SAP_Automated_Deployment
    mkdir -p WORKSPACES/DEPLOYER
    cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/DEPLOYER/MGMT-WEEU-DEP00-INFRASTRUCTURE WORKSPACES/DEPLOYER/. -r

    mkdir -p WORKSPACES/LIBRARY
    cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/LIBRARY/MGMT-WEEU-SAP_LIBRARY WORKSPACES/LIBRARY/. -r

    mkdir -p WORKSPACES/LANDSCAPE
    cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/LANDSCAPE/DEV-WEEU-SAP01-INFRASTRUCTURE WORKSPACES/LANDSCAPE/. -r

    mkdir -p WORKSPACES/SYSTEM
    cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/SYSTEM/DEV-WEEU-SAP01-X00 WORKSPACES/SYSTEM/. -r
    cd WORKSPACES

```

### **Scenario 1 - Prepare the region** ###

The deployer and library can be deployed using the ***prepare_region.sh*** command. Before executing this command ensure that you have the details for the Service Principal that will be used to deploy the artifacts. 

For Service Principal creation see [Service Principal Creation](./spn.md).
Substitute the Service Principal values in the script below before running the script.

**prepare_region.sh** bash script:

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES

    $DEPLOYMENT_REPO_PATH/scripts/prepare_region.sh
        --deployer_parameter_file DEPLOYER/MGMT-WEEU-DEP00-INFRASTRUCTURE/MGMT-WEEU-DEP00-INFRASTRUCTURE.json \
        --library_parameter_file LIBRARY/MGMT-WEEU-SAP_LIBRARY/MGMT-WEEU-SAP_LIBRARY.json
        --subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
        --spn_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy \
        --spn_secret ************************ \
        --tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz \
        --auto-approve

```

**New-SAPAutomationRegion** PowerShell cmdlet:

```PowerShell
    New-SAPAutomationRegion 
    -DeployerParameterfile .\DEPLOYER\MGMT-EUS2-DEP01-INFRASTRUCTURE\MGMT-EUS2-DEP01-INFRASTRUCTURE.json 
    -LibraryParameterfile .\LIBRARY\MGMT-EUS2-SAP_LIBRARY\MGMT-EUS2-SAP_LIBRARY.json 
    -Subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx 
    -SPN_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy 
    -SPN_password  ************************ 
    -Tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz 
    -Silent             
```

### **Scenario 1 - Deploy the workload** ###

Before the actual SAP system can be deployed a workload zone needs to be prepared. For deploying the DEV workload zone (vnet & keyvaults) navigate to the folder(LANDSCAPE/DEV-WEEU-SAP01-INFRASTRUCTURE) containing the DEV-WEEU-SAP01-INFRASTRUCTURE.json parameter file and use the install_workloadzone script.

For Service Principal creation see [Service Principal Creation](./spn.md).
Substitute your Service Principal values in the script below before running the script.

**install_workloadzone.sh** bash script:

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/LANDSCAPE/DEV-WEEU-SAP01-INFRASTRUCTURE

    ${DEPLOYMENT_REPO_PATH}deploy/scripts/install_workloadzone.sh --parameterfile DEV-WEEU-SAP01-INFRASTRUCTURE.json \
    --deployer_environment MGMT
    --subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
    --spn_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy \
    --spn_secret ************************ \
    --tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz \
    --auto-approve
```

**New-SAPWorkloadZone** PowerShell cmdlet:

```PowerShell
    cd \Azure_SAP_Automated_Deployment\WORKSPACES\LANDSCAPE\DEV-NOEU-SAP02-INFRASTRUCTURE

    New-SAPWorkloadZone --parameterfile .\DEV-NOEU-SAP02-INFRASTRUCTURE.json 
        -DeployerEnvironment MGMT
        -Subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx 
        -SPN_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy 
        -SPN_password ************************ 
        -Tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz 

```

### **Scenario 1 - Deploying the SAP system** ###

For deploying the SAP system navigate to the folder(DEV-WEEU-SAP01-X00) containing the DEV-WEEU-SAP01-X00.json parameter file and use the installer.sh script.

**installer.sh** bash script:

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SYSTEM/DEV-WEEU-SAP01-X00

    ${DEPLOYMENT_REPO_PATH}deploy/scripts/installer.sh --parameterfile DEV-WEEU-SAP01-X00.json --type sap_system --auto-approve
```

**New-SAPSystem** PowerShell cmdlet:

```PowerShell
    cd \Azure_SAP_Automated_Deployment\WORKSPACES\SYSTEM\DEV-WEEU-SAP01-X00

    New-SAPSystem --parameterfile .\DEV-WEEU-SAP01-X00.json 
        -Type sap_system

```


<br>

## **Scenario 2 - Greenfield deployment without the deployer** ##

This scenario contains the following deployments:

- Library
- Workload
- System: SID X00, with a single Application Server,  a Central Services instance and single node HANA backend all using Redhat 7.7

A sample configuration for this is available here:

| Component                | Template |
| :------------------------| :----------------------------------------------------------------------- |
| Library                  | [LIBRARY/MGMT-NOEU-SAP_LIBRARY/MGMT-NOEU-SAP_LIBRARY.json](./WORKSPACES/LIBRARY/MGMT-NOEU-SAP_LIBRARY/MGMT-NOEU-SAP_LIBRARY.json) |
| Workload                 | [DEV-NOEU-SAP02-INFRASTRUCTURE.json](./WORKSPACES//LANDSCAPE/DEV-NOEU-SAP02-INFRASTRUCTURE/DEV-NOEU-SAP02-INFRASTRUCTURE.json) |
| System                   | [DEV-NOEU-SAP02-X02/DEV-NOEU-SAP02-X02.json](./WORKSPACES/SYSTEM/DEV-NOEU-SAP02-X02/DEV-NOEU-SAP02-X02.json) |

<br>

From the cloned repository copy the following folders to your root folder (*Azure_SAP_Automated_Deployment/WORKSPACES*) for parameter files

- LIBRARY/MGMT-NOEU-SAP_LIBRARY
- LANDSCAPE/DEV-NOEU-SAP02-INFRASTRUCTURE
- SYSTEM/DEV-NOEU-SAP01-X02

The helper script below can be used to copy the folders.

```bash
cd ~/Azure_SAP_Automated_Deployment

mkdir -p WORKSPACES/LIBRARY
cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/LIBRARY/MGMT-NOEU-SAP_LIBRARY WORKSPACES/LIBRARY/. -r

mkdir -p WORKSPACES/LANDSCAPE
cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/LANDSCAPE/DEV-NOEU-SAP02-INFRASTRUCTURE WORKSPACES/LANDSCAPE/. -r

mkdir -p WORKSPACES/SYSTEM
cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/SYSTEM/DEV-NOEU-SAP02-X02 WORKSPACES/SYSTEM/. -r
cd WORKSPACES
```

The scenario requires an existing key vault that contains the SPN credentials for the SPN that will be used to deploy the workload zone. This must be defined in the parameter file with the kv_spn_id parameter.

```json
"key_vault" : {
    "kv_spn_id"         : "<ARMresourceID>"
} 
```

By providing false in the "use" attribute in the deployer section, the automation framwork will not use any information from the deployer state file.

```json
"deployer" : {
    "use": false
} 
```

### **Scenario 2 - Deploy the library** ###

The deployer and library can be deployed using the ***install_library.sh*** command. Update the MGMT-NOEU-SAP_LIBRARY.json file and add the resource id for the keyvault containing the service principal details.

**install_library.sh** bash script:

```bash

    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/LIBRARY/MGMT-NOEU-SAP_LIBRARY

    $DEPLOYMENT_REPO_PATH/deploy/scripts/install_library.sh --parameterfile MGMT-NOEU-SAP_LIBRARY.json 
```

Capture the value for the remote_state_storage_account_name from the output of the previous command and migrate the terrraform state to Azure using:

```bash

    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/LIBRARY/MGMT-NOEU-SAP_LIBRARY

    $DEPLOYMENT_REPO_PATH/deploy/scripts/installer.sh --parameterfile MGMT-NOEU-SAP_LIBRARY.json --type sap_library
```


**New-SAPLibrary** PowerShell cmdlet:

```PowerShell

    cd Azure_SAP_Automated_Deployment\WORKSPACES\LIBRARY\MGMT-NOEU-SAP_LIBRARY

    New-SAPLibrary --parameterfile .\MGMT-NOEU-SAP_LIBRARY.json 

```

Capture the value for the remote_state_storage_account_name from the output of the previous command and migrate the terrraform state to Azure using:

**New-SAPSystem** PowerShell cmdlet:

```PowerShell

    cd Azure_SAP_Automated_Deployment\WORKSPACES\LIBRARY\MGMT-NOEU-SAP_LIBRARY

    New-SAPSystem --parameterfile .\MGMT-WUS2-SAP_LIBRARY.json -Type sap_library -TFStateStorageAccountName mgmtwus2tfstate###   

```

### **Scenario 2 - Deploy the workload** ###

The deployer and library can be deployed using the ***install_library.sh*** command. Update the MGMT-NOEU-SAP_LIBRARY.json file and add the resource id for the keyvault containing the service principal details.

**install_workloadzone.sh** bash script:

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/LANDSCAPE/DEV-NOEU-SAP02-INFRASTRUCTURE

     $DEPLOYMENT_REPO_PATH/deploy/scripts/install_workloadzone.sh --parameter_file DEV-NOEU-SAP02-INFRASTRUCTURE.json \
     --state_subscription wwwwwwww-wwww-wwww-wwww-wwwwwwwwwwww \
     --storageaccountname mgmtweeutfstate### \
     --vault MGMTWEEUDEP00user### \
     --subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
     --spn_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy \
     --spn_secret ************************ \
     --tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz 
```

**New-SAPWorkloadZone** PowerShell cmdlet:

```PowerShell
    cd \Azure_SAP_Automated_Deployment\WORKSPACES\LANDSCAPE\DEV-NOEU-SAP02-INFRASTRUCTURE

    New-SAPWorkloadZone --parameterfile .\DEV-NOEU-SAP02-INFRASTRUCTURE.json 
        -State_subscription wwwwwwww-wwww-wwww-wwww-wwwwwwwwwwww 
        -Vault MGMTWEEUDEP00user###
        -StorageAccountName mgmtweeutfstate 
        -Subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx 
        -SPN_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy 
        -SPN_password ************************ 
        -Tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz 

```

### **Scenario 2 - Deploying the SAP system** ###

For deploying the SAP system navigate to the folder(DEV-NOEU-SAP02-X02) containing the DEV-NOEU-SAP02-X02.json parameter file and use the installer.sh script.

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SYSTEM/DEV-NOEU-SAP02-X02

    ${DEPLOYMENT_REPO_PATH}deploy/scripts/installer.sh --parameterfile DEV-NOEU-SAP02-X02.json --type sap_system --auto-approve
```
**New-SAPSystem** PowerShell cmdlet:

```PowerShell
    cd \Azure_SAP_Automated_Deployment\WORKSPACES\SYSTEM\DEV-NOEU-SAP02-X02

    New-SAPSystem --parameterfile .\DEV-NOEU-SAP02-X02.json 
        -Type sap_system

```

<br>

# Brownfield deployment #

In this scenario the deployment will be performed using existing resource groups, storage accounts, virtual networks, subnets and network security groups.

## **Scenario 3 - Brownfield deployment using the deployer** ##

In this scenario the Azure artifacts will be deployed into an existing Azure environment. The deployment includes two environments "MGMT" and "QA". Both environments need a Service Principal registered in the deployer key vault.

This scenario contains the following deployments

- Deployer
- Library
- Workload
- System: SID X01, with 2 Application Servers, a highly available Central Services instance, a single webdispatcher all Windows Server 2016, using a Microsoft SQL Server backend using.

A sample configuration for this is available here:

| Component                | Template |
| :------------------------| :----------------------------------------------------------------------- |
| Deployer                 | [DEPLOYER/MGMT-EUS2-DEP01-INFRASTRUCTURE/MGMT-EUS2-DEP01-INFRASTRUCTURE.json](./WORKSPACES/DEPLOYER/MGMT-EUS2-DEP00-INFRASTRUCTURE/MGMT-EUS2-DEP01-INFRASTRUCTURE.json)
| Library                  | [LIBRARY/MGMT-EUS2-SAP_LIBRARY/MGMT-EUS2-SAP_LIBRARY.json](./WORKSPACES/LIBRARY/MGMT-EUS2-SAP_LIBRARY/MGMT-EUS2-SAP_LIBRARY.json)
| Workload                 | [LANDSCAPE/QA-EUS2-SAP03-INFRASTRUCTURE/QA-EUS2-SAP03-INFRASTRUCTURE.json](./WORKSPACES//LANDSCAPE/QA-EUS2-SAP03-INFRASTRUCTURE/QA-EUS2-SAP03-INFRASTRUCTURE.json)
| System                   | [SYSTEM/QA-EUS2-SAP03-X01/QA-EUS2-SAP03-X01.json](./WORKSPACES/SYSTEM/QA-EUS2-SAP03-X01/QA-EUS2-SAP03-X01.json)

<br>

From the cloned repository copy the following folders to your root folder (*Azure_SAP_Automated_Deployment/WORKSPACES*) for parameter files

- DEPLOYER/MGMT-EUS2-DEP00-INFRASTRUCTURE
- LIBRARY/MGMT-EUS2-SAP_LIBRARY
- LANDSCAPE/QA-EUS2-SAP03-INFRASTRUCTURE
- SYSTEM/QA-EUS2-SAP03-X01

The helper script below can be used to copy the pertinent folders.

```bash
    cd ~/Azure_SAP_Automated_Deployment
    mkdir -p WORKSPACES/DEPLOYER
    cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/DEPLOYER/MGMT-EUS2-DEP01-INFRASTRUCTURE WORKSPACES/DEPLOYER/. -r

    mkdir -p WORKSPACES/LIBRARY
    cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/LIBRARY/MGMT-EUS2-SAP_LIBRARY WORKSPACES/LIBRARY/. -r

    mkdir -p WORKSPACES/LANDSCAPE
    cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/LANDSCAPE/QA-EUS2-SAP03-INFRASTRUCTURE WORKSPACES/LANDSCAPE/. -r

    mkdir -p WORKSPACES/SYSTEM
    cp sap-hana/documentation/SAP_Automation_on_Azure/Process_Documentation/WORKSPACES/SYSTEM/QA-EUS2-SAP03-X01 WORKSPACES/SYSTEM/. -r
    cd WORKSPACES

```

### **Scenario 3 - Prepare the region** ###

The deployer and library can be deployed using the ***prepare_region.sh*** command. Before executing this command ensure that you have the details for the Service Principal that will be used to deploy the artifacts.

For Service Principal creation see [Service Principal Creation](./spn.md).
Substitute you Service Principal values in the script below before running the script.

**prepare_region.sh** bash script:

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES

    $DEPLOYMENT_REPO_PATH/scripts/prepare_region.sh
        --deployer_parameter_file DEPLOYER/MGMT-EUS2-DEP01-INFRASTRUCTURE/MGMT-EUS2-DEP01-INFRASTRUCTURE.json \
        --library_parameter_file LIBRARY/MGMT-EUS2-SAP_LIBRARY/MGMT-EUS2-SAP_LIBRARY.json
        --subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
        --spn_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy \
        --spn_secret ************************ \
        --tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz \
        --auto-approve

```

**New-SAPAutomationRegion** PowerShell cmdlet:

```PowerShell
    New-SAPAutomationRegion 
    -DeployerParameterfile .\DEPLOYER\MGMT-EUS2-DEP01-INFRASTRUCTURE\MGMT-EUS2-DEP01-INFRASTRUCTURE.json 
    -LibraryParameterfile .\LIBRARY\MGMT-EUS2-SAP_LIBRARY\MGMT-EUS2-SAP_LIBRARY.json 
    -Subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx 
    -SPN_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy 
    -SPN_password  ************************ 
    -Tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz 
    -Silent             
```

### **Scenario 3 - Deploy the workload** ###

Before the actual SAP system can be deployed a workload zone needs to be prepared. For deploying the QA workload zone (vnet & keyvaults) navigate to the folder(LANDSCAPE/QA-EUS2-SAP03-INFRASTRUCTURE) containing the QA-EUS2-SAP03-INFRASTRUCTURE.json parameter file and use the install_workloadzone script.

For Service Principal creation see [Service Principal Creation](./spn.md).
Substitute you Service Principal values in the script below before running the script.

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/LANDSCAPE/QA-EUS2-SAP03-INFRASTRUCTURE

    ${DEPLOYMENT_REPO_PATH}deploy/scripts/install_workloadzone.sh --parameterfile QA-EUS2-SAP03-INFRASTRUCTURE.json \
    --deployer_environment MGMT
    --subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
    --spn_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy \
    --spn_secret ************************ \
    --tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz \
    --auto-approve
```

### **Scenario 3 - Deploying the SAP system** ###

For deploying the SAP system navigate to the folder(QA-EUS2-SAP03-X01) containing the QA-EUS2-SAP03-X01.json parameter file and use the installer.sh script.


**installer.sh** bash script:

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SYSTEM/QA-EUS2-SAP03-X01

    ${DEPLOYMENT_REPO_PATH}deploy/scripts/installer.sh --parameterfile QA-EUS2-SAP03-X01.json --type sap_system --auto-approve
```

**New-SAPSystem** PowerShell cmdlet:

```PowerShell
    cd \Azure_SAP_Automated_Deployment\WORKSPACES\SYSTEM\QA-EUS2-SAP03-X01

    New-SAPSystem --parameterfile .\QA-EUS2-SAP03-X01.json 
        -Type sap_system

```

## Scenario 4 **Brownfield deployment without the deployer** ##

This scenario contains the following deployments:

- Library
- Workload(s)
- System(s)

A sample configuration for this is available here

| Component                | Template |
| :------------------------|  :----------------------------------------------------------------------- |
| Library                  | [MGMT-WUS2-SAP_LIBRARY/MGMT-WUS2-SAP_LIBRARY.json](./WORKSPACES/LIBRARY/MGMT-WUS2-SAP_LIBRARY/MGMT-WUS2-SAP_LIBRARY.json) |
| Workload                 | [QA-WUS2-SAP04-INFRASTRUCTURE/QA-WUS2-SAP04-INFRASTRUCTURE.json](./WORKSPACES/LANDSCAPE/QA-WUS2-SAP04-INFRASTRUCTURE/QA-WUS2-SAP04-INFRASTRUCTURE.json) |
| System                   | [QA-WUS2-SAP04-X03/QA-WUS2-SAP04-X03.json](./WORKSPACES/SYSTEM/QA-WUS2-SAP04-X03/QA-WUS2-SAP04-X03.json)

The scenario requires an existing key vault that contains the SPN credentials for the SPN that will be used to deploy the workload zone. This can be defined in the parameter file with the kv_spn_id parameter.

```json
"key_vault" : {
    "kv_spn_id"         : "<ARMresourceID>"
} 

By providing false in the "use" attribute in the deployer section, the automation framwork will not use any information from the deployer state file.

```json
"deployer" : {
    "use": false
} 
```

### **Scenario 4 - Deploy the library** ###

The deployer and library can be deployed using the ***install_library.sh*** command. Update the MGMT-WUS2-SAP_LIBRARY.json file and add the resource id for the keyvault containing the service principal details.

**install_library.sh** bash script:

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/LIBRARY/MGMT-WUS2-SAP_LIBRARY

    $DEPLOYMENT_REPO_PATH/deploy/scripts/install_library.sh --parameterfile MGMT-WUS2-SAP_LIBRARY.json 

```

**New-SAPLibrary** PowerShell cmdlet:

```PowerShell

    New-SAPLibrary --parameterfile .\MGMT-WUS2-SAP_LIBRARY.json 

```

Capture the value for the remote_state_storage_account_name from the output of the previous command and migrate the terrraform state to Azure using:

**New-SAPSystem** PowerShell cmdlet:

```PowerShell

New-SAPSystem --parameterfile .\MGMT-WUS2-SAP_LIBRARY.json -Type sap_library -TFStateStorageAccountName mgmtwus2tfstate###   

```

### **Scenario 4 - Deploy the workload** ###

Update the QA-WUS2-SAP04-INFRASTRUCTURE.json file and add the resource id for the keyvault containing the service principal details.

**install_workloadzone.sh** bash script:

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/LANDSCAPE/QA-WUS2-SAP04-INFRASTRUCTURE

     $DEPLOYMENT_REPO_PATH/deploy/scripts/install_workloadzone.sh --parameter_file QA-WUS2-SAP04-INFRASTRUCTURE.json \
     --state_subscription wwwwwwww-wwww-wwww-wwww-wwwwwwwwwwww \
     --storageaccountname mgmteus2tfstate### \
     --vault MGMTEUS2DEP02user### \
     --subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
     --spn_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy \
     --spn_secret ************************ \
     --tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz 
```

**New-SAPWorkloadZone** PowerShell cmdlet:

```PowerShell
    cd \Azure_SAP_Automated_Deployment\WORKSPACES\LANDSCAPE\QA-WUS2-SAP04-INFRASTRUCTURE

    New-SAPWorkloadZone --parameterfile .\QA-WUS2-SAP04-INFRASTRUCTURE.json 
        -State_subscription wwwwwwww-wwww-wwww-wwww-wwwwwwwwwwww 
        -Vault MGMTEUS2DEP02user### \
        -StorageAccountName mgmteus2tfstate 
        -Subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx 
        -SPN_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy 
        -SPN_password ************************ 
        -Tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz 

```

### **Scenario 4 - Deploying the SAP system** ###

For deploying the SAP system navigate to the folder(QA-WUS2-SAP04-X03) containing the QA-WUS2-SAP04-X03.json parameter file and use the installer.sh script.

```bash

    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SYSTEM/QA-WUS2-SAP04-X03

    ${DEPLOYMENT_REPO_PATH}deploy/scripts/installer.sh --parameterfile QA-WUS2-SAP04-X03.json --type sap_system --auto-approve

```

**New-SAPSystem** PowerShell cmdlet:

```PowerShell
    cd \Azure_SAP_Automated_Deployment\WORKSPACES\SYSTEM\QA-WUS2-SAP04-X03

    New-SAPSystem --parameterfile .\QA-WUS2-SAP04-X03.json 
        -Type sap_system

```

