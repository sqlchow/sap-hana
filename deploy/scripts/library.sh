
# Provide the relative path to the repository root folder
repo_path='../../../sap-hana' 
#Provide the name if the input parameter file (*.json)
input='deployer.json'

#Provide the subscription name
subscription='' 
#Provide the resource group name for the SAP Library
saplib_rg=''
#Provide the storage account name for the SAP Library tfstate storage account
tfstate_sa_name=''
#Provide the deployer state file
sap_deployer_key='' 

# If remote storage is in use
remote_storage='Y'

if $(remote_storage) = 'Y'
terraform init -upgrade=true --backend-config "subscription_id=$(subscription)" \
    --backend-config "resource_group_name=${saplib_rg}" \
    --backend-config "storage_account_name=${tfstate_sa_name}" \
    --backend-config "container_name=tfstate" \
    --backend-config "key=${sap_deployer_key}" \
    ${repo_path}/deploy/terraform/run/sap_library/
terraform plan -var-file=${input} ${repo_path}/deploy/terraform/run/sap_library/ > plan_output.log
else
terraform init -upgrade=true ${repo_path}/deploy/terraform/bootstrap/sap_library/
terraform plan -var-file=${input} ${repo_path}/deploy/terraform/bootstrap/sap_library/ > plan_output.log
fi

if ! grep "No changes\|0 to change, 0 to destroy" plan_output.log; then 
echo "Risk for Data loss"; 
fi;