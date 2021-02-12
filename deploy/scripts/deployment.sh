#!/bin/bash

#Provide the environment state file
terraform_state_key=$1

#Provide the name if the input parameter file (*.json)
input_json=$2

# Provide the relative path to the parameter folder
folder_path=$3

# Provide the relative path to the repository root folder
repo_path=$4

if [ $5 == true ]; then
    echo "Interactive"
else
    approve="--auto-approve"
fi

deployment_system=$6

ok_to_proceed=false
new_deployment=false
cd ${folder_path}

echo "####################################################" > backend.tf
echo "# To overcome terraform issue                      #" >> backend.tf
echo "####################################################" >> backend.tf
echo "terraform {"                                          >> backend.tf
echo " backend \"azurerm\" {}"                              >> backend.tf
echo "}"                                                    >> backend.tf

terraform init -upgrade=true --backend-config "subscription_id=${ARM_SUBSCRIPTION_ID}" \
--backend-config "resource_group_name=${REMOTE_STATE_RG}" \
--backend-config "storage_account_name=${REMOTE_STATE_SA}" \
--backend-config "container_name=tfstate" \
--backend-config "key=${terraform_state_key}" \
${repo_path}/deploy/terraform/run/${deployment_system}/

outputs=`terraform output`
if echo $outputs | grep "No outputs"; then
    ok_to_proceed=true
    new_deployment=true
    echo ""
    echo "####################################"
    echo "#        New Deployment            #"
    echo "####################################"
    echo ""
else
    echo ""
    echo "####################################"
    echo "# Existing deployment was detected #"
    echo "####################################"
    echo ""
    deployed_using_version=`terraform output automation_version`
    if [ ! -n "$deployed_using_version" ]; then
        echo ""
        echo "####################################"
        echo "#!!! Risk for Data loss!!!         #"
        echo "####################################"
        
        read -p "Do you want to continue Y/N?"  ans
        answer=${ans^^}
        if [ $answer == 'Y' ]; then
            ok_to_proceed=true
        else
            exit 1
        fi
    else
        echo ""
        echo "############################################################################"
        echo "# Terraform templates version" $deployed_using_version "were used in the deployment"
        echo "############################################################################"
        echo ""
        #Add version logic here
    fi
fi

echo ""
echo "####################################"
echo "# Running Terraform plan           #"
echo "####################################"
echo ""
terraform plan -var-file=${input_json} ${repo_path}/deploy/terraform/run/${deployment_system}/ > plan_output.log

if ! $new_deployment; then
    if grep "No changes" plan_output.log ; then
        echo ""
        echo "#################################"
        echo "# Infrastructure is up to date  #"
        echo "#################################"
        echo ""
        rm plan_output.log
        exit 0
    fi
    if ! grep "0 to change, 0 to destroy" plan_output.log ; then
        echo ""
        echo "####################################"
        echo "#!!! Risk for Data loss!!!         #"
        echo "####################################"
        
        read -p "Do you want to continue Y/N?"  ans
        answer=${ans^^}
        if [ $answer == 'Y' ]; then
            ok_to_proceed=true
        else
            exit 1
        fi
    else
        ok_to_proceed=true
    fi
fi

if [ $ok_to_proceed ]; then
    cat plan_output.log
    rm plan_output.log
    
    echo ""
    echo "####################################"
    echo "# Running Terraform apply          #"
    echo "####################################"
    echo ""
    
    terraform apply ${approve} -var-file=${input_json} ${repo_path}/deploy/terraform/run/${deployment_system}/
    
fi
