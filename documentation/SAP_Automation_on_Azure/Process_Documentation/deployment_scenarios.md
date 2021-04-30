# ![SAP Deployment Automation Framework](../assets/images/UnicornSAPBlack64x64.png)**SAP Deployment Automation Framework** #

# Deployment Scenarios #

The SAP Deployment Automation Framework support the following deployment models:

## **Scenario 1 - Greenfield using the deployer** ##

In this scenario all Azure artifacts will be created by the automation framework. The deployment includes two environments "MGMT" and "DEV". Both environments need a Service Principal registered in the deployer key vault.

This scenario contains the following deployments

- Deployer
- Library
- Workload(s)
- System(s)

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
Substitute you Service Principal values in the script below before running the script.

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

### **Scenario 1 - Deploy the workload** ###

Before the actual SAP system can be deployed a workload zone needs to be prepared. For deploying the DEV workload zone (vnet & keyvaults) navigate to the folder(LANDSCAPE/DEV-WEEU-SAP01-INFRASTRUCTURE) containing the DEV-WEEU-SAP01-INFRASTRUCTURE.json parameter file and use the install_workloadzone script.

For Service Principal creation see [Service Principal Creation](./spn.md).
Substitute you Service Principal values in the script below before running the script.


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

### **Scenario 1 - Deploying the SAP system** ###

For deploying the SAP system navigate to the folder(DEV-WEEU-SAP01-X00) containing the DEV-WEEU-SAP01-X00.json parameter file and use the installer.sh script.

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/SYSTEM/DEV-WEEU-SAP01-X00

    ${DEPLOYMENT_REPO_PATH}deploy/scripts/installer.sh --parameterfile DEV-WEEU-SAP01-X00.json --type sap_system --silect
```

<br>

## **Greenfield deployment without the deployer** ##

This scenario contains the following deployments:

- Library
- Workload(s)
- System(s)

A sample configuration for this is available here:

| Component                | Template |
| :------------------------| :----------------------------------------------------------------------- |
| Library                  | [LIBRARY/MGMT-NOEU-SAP_LIBRARY/MGMT-NOEU-SAP_LIBRARY.json](./WORKSPACES/LIBRARY/MGMT-NOEU-SAP_LIBRARY/MGMT-NOEU-SAP_LIBRARY.json) |
| Workload                 | [DEV-NOEU-SAP02-INFRASTRUCTURE.json](./WORKSPACES//LANDSCAPE/DEV-NOEU-SAP02-INFRASTRUCTURE/DEV-NOEU-SAP02-INFRASTRUCTURE.json) |
| System                   | [DEV-NOEU-SAP02-X02/DEV-NOEU-SAP02-X02.json](./WORKSPACES/SYSTEM/DEV-NOEU-SAP02-X02/DEV-NOEU-SAP02-X02.json) |

<br>

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

The deployer and library can be deployed using the ***install_library.sh*** command. .

```bash
    cd ~/Azure_SAP_Automated_Deployment/WORKSPACES/LIBRARY/MGMT-NOEU-SAP_LIBRARY

    $DEPLOYMENT_REPO_PATH/scripts/install_library.sh
        --deployer_parameter_file DEPLOYER/MGMT-WEEU-DEP00-INFRASTRUCTURE/MGMT-WEEU-DEP00-INFRASTRUCTURE.json \
        --library_parameter_file LIBRARY/MGMT-WEEU-SAP_LIBRARY/MGMT-WEEU-SAP_LIBRARY.json
        --subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
        --spn_id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy \
        --spn_secret ************************ \
        --tenant_id zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz \
        --auto-approve

```


# Brownfield deployment #

In this scenario the deployment will be performed using existing virtual networks, subnets and network security groups.

## **Brownfield deployment using the deployer** ##

This scenario contains the following deployments

- Deployer
- Library
- Workload(s)
- System(s)

A sample configuration for this is available here

| Component                | Template |
| :------------------------|  :----------------------------------------------------------------------- |
| Deployer                 | [Deployer](./WORKSPACES/DEPLOYER/MGMT-EUS2-DEP01-INFRASTRUCTURE/MGMT-EUS2-DEP01-INFRASTRUCTURE.json) |  
| Library                  | [Library](./WORKSPACES/LIBRARY/MGMT-EUS2-SAP_LIBRARY/MGMT-EUS2-SAP_LIBRARY.json) |  
| Workload                 | [Workload](./WORKSPACES//LANDSCAPE/QA-EUS2-SAP03-INFRASTRUCTURE/QA-EUS2-SAP03-INFRASTRUCTURE.json) |  
| System                   | [System](./WORKSPACES/SYSTEM/QA-EUS2-SAP03-X01/QA-EUS2-SAP03-X01.json) |  

## **Brownfield deployment without the deployer** ##

This scenario contains the following deployments:

- Library
- Workload(s)
- System(s)

A sample configuration for this is available here

| Component                | Template |
| :------------------------|  :----------------------------------------------------------------------- |
| Library                  | [Library](./WORKSPACES/LIBRARY/MGMT-WUS2-SAP_LIBRARY/MGMT-WUS2-SAP_LIBRARY.json)
| Workload                 | [Workload](./WORKSPACES/LANDSCAPE/QA-WUS2-SAP04-INFRASTRUCTURE/QA-WUS2-SAP04-INFRASTRUCTURE.json)
| System                   | [Library](./WORKSPACES/SYSTEM/QA-WUS2-SAP04-X03/QA-WUS2-SAP04-X03.json)

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

