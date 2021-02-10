
# Provide the relative path to the repository root folder
repo_path='../../../sap-hana' 
#Provide the name if the input parameter file (*.json)
input='environment.json'

#Provide the subscription name
subscription='' 
#Provide the resource group name for the SAP Library
saplib_rg=''
#Provide the storage account name for the SAP Library tfstate storage account
tfstate_sa_name=''
#Provide the environment state file
sap_system_key='' 

terraform init -upgrade=true --backend-config "subscription_id=$(subscription)" \
    --backend-config "resource_group_name=${saplib_rg}" \
    --backend-config "storage_account_name=${tfstate_sa_name}" \
    --backend-config "container_name=tfstate" \
    --backend-config "key=${sap_system_key}" \
    ${repo_path}/deploy/terraform/run/sap_landscape/
terraform plan -var-file=${input} ${repo_path}/deploy/terraform/run/sap_system/ > plan_output.log
     
if ! grep "No changes\|0 to change, 0 to destroy" plan_output.log; then 
exit 1; 
fi;