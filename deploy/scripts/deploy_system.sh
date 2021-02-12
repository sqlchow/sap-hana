#!/bin/bash

export ARM_SUBSCRIPTION_ID='<SUBSCRIPTIONID>'
export REMOTE_STATE_RG='<STATEFILE_RG_NAME>'
export REMOTE_STATE_SA='STATEFILE_SA_NAME'

#Provide the environment state file
terraform_state_key=$1

#Provide the name of the input parameter file (*.json)
input_parameter_json=$2

# Provide the relative path to the folder that contains the parameter files for the system
relative_path_to_folder_with_parameters=$3

# Provide the relative path to the repository root folder from the parameter folder,
relative_path_to_saphana='../../../sap-hana'

# Define if the automation will prompt before applying 
prompt_before_apply=true

# Define the system to be deployed
# deployer = sap_deployer, this is the deployment infrastructure
# library = sap_library, this will provide storage for Terraform state files and the SAP binaries 
# environment = sap_landscape, this will contain the workload vnet and the workload keyvault
# system = sap_system,  this is the infrastructure for the SAP Application

system_type=$4

${relative_path_to_saphana}/deploy/scripts/deployment.sh $terraform_state_key $input_parameter_json $relative_path_to_folder_with_parameters $relative_path_to_saphana $prompt_before_apply $system_type
