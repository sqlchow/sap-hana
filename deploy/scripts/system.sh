
#Provide the environment state file
sap_system_key=$1

#Provide the name if the input parameter file (*.json)
input=$2

# Provide the relative path to the parameter folder
folder_path=$3

# Provide the relative path to the repository root folder
repo_path=$4

ok_to_proceed='N'

cd ${folder_path}


terraform init -upgrade=true --backend-config "subscription_id=${ARM_SUBSCRIPTION_ID}" \
    --backend-config "resource_group_name=${REMOTE_STATE_RG}" \
    --backend-config "storage_account_name=${REMOTE_STATE_SA}" \
    --backend-config "container_name=tfstate" \
    --backend-config "key=${sap_system_key}" \
    ${repo_path}/deploy/terraform/run/sap_landscape/

if "terraform output |  grep Warning: No outputs" ;then´ `
terraform output > outputs.log
if grep "Warning: No outputs found" outputs.log; then 
    ok_to_proceed='Y'
else
    terraform output automation_version > version.log
    version=$(< version.log)
fi

terraform plan -var-file=${input} ${repo_path}/deploy/terraform/run/sap_system/ > plan_output.log
if ! grep "No changes\|0 to change, 0 to destroy" plan_output.log; then 
    echo "Risk for Data loss"; 
else
    ok_to_proceed='Y'
fi

if $version="v2.3.3.1"; then
 echo "Danger"
 ok_to_proceed='N'
fi 

if ok_to_proceed='Y'; then
    terraform apply -var-file=${input} ${repo_path}/deploy/terraform/run/sap_system/ 
fi

rm outputs.log
rm version.log
