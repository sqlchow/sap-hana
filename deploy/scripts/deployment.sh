#!/bin/bash

# parameterfile
parameterfile=$1

repo_path=$HOME/Azure_SAP_Automated_Deployment/sap-hana

# Read environment for later use
readarray -d '-' -t environment<<<"$parameterfile"

key=`echo $parameterfile | cut -d. -f1`

if [ $3 == false ]; then
    approve="--auto-approve"
fi

deployment_system=$2

if [ ! -n "$ARM_SUBSCRIPTION_ID" ]; then
        echo ""
        echo "####################################################################################"
        echo "# Missing environment variables (ARM_SUBSCRIPTION_ID)!!!                           #"
        echo "# Please export the folloing variables:                                            #"
        echo "# ARM_SUBSCRIPTION_ID (subscription containing the state file storage account)     #"
        echo "# REMOTE_STATE_RG (resource group name for storage account containing state files) #"
        echo "# REMOTE_STATE_SA (storage account for state file)                                 #"
        echo "####################################################################################"
        exit 3
fi

if [ ! -n "$REMOTE_STATE_RG" ]; then
        echo ""
        echo "####################################################################################"
        echo "# Missing environment variables (REMOTE_STATE_RG)!!!                               #"
        echo "# Please export the folloing variables:                                            #"
        echo "# ARM_SUBSCRIPTION_ID (subscription containing the state file storage account)     #"
        echo "# REMOTE_STATE_RG (resource group name for storage account containing state files) #"
        echo "# REMOTE_STATE_SA (storage account for state file)                                 #"
        echo "####################################################################################"
        exit 3
fi

if [ ! -n "$REMOTE_STATE_SA" ]; then
        echo ""
        echo "####################################################################################"
        echo "# Missing environment variables REMOTE_STATE_SA!!!                                 #"
        echo "# Please export the folloing variables:                                            #"
        echo "# ARM_SUBSCRIPTION_ID (subscription containing the state file storage account)     #"
        echo "# REMOTE_STATE_RG (resource group name for storage account containing state files) #"
        echo "# REMOTE_STATE_SA (storage account for state file)                                 #"
        echo "####################################################################################"
        exit 3
fi

if [ ! -d ${repo_path}/deploy/terraform/run/${deployment_system} ]
then
    echo "####################################################################################"
    echo "# Incorrect system deployment type specified :" ${deployment_system} "       #"
    echo "# Valid options are:                                                               #"   
    echo "# sap_deployer                                                                     #" 
    echo "# sap_library                                                                      #" 
    echo "# sap_landscape                                                                    #" 
    echo "# sap_system                                                                       #" 
    echo "####################################################################################"
    echo ""
    exit 1
fi


ok_to_proceed=false
new_deployment=false

cat <<EOF > backend.tf
####################################################
# To overcome terraform issue                      #
####################################################
terraform {
    backend "azurerm" {}
}

EOF

terraform init -upgrade=true --backend-config "subscription_id=${ARM_SUBSCRIPTION_ID}" \
--backend-config "resource_group_name=${REMOTE_STATE_RG}" \
--backend-config "storage_account_name=${REMOTE_STATE_SA}" \
--backend-config "container_name=tfstate" \
--backend-config "key=${key}.terraform.tfstate" \
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
        echo "####################################################################################"
    echo "# Existing deployment was detected #"
        echo "####################################################################################"
    echo ""
    deployed_using_version=`terraform output automation_version`
    if [ ! -n "$deployed_using_version" ]; then
        echo ""
        echo "####################################################################################"
        echo "#                             !!! Risk for Data loss !!!                           #"
        echo "#                    Please run Terraform plan and inspect the output .            #"
        echo "####################################################################################"

        read -p "Do you want to continue Y/N?"  ans
        answer=${ans^^}
        if [ $answer == 'Y' ]; then
            ok_to_proceed=true
        else
            exit 1
        fi
    else
        echo ""
        echo "####################################################################################"
        echo "# Terraform templates version" $deployed_using_version "were used in the deployment #"
        echo "####################################################################################"
        echo ""
        #Add version logic here
    fi
fi

echo ""
echo "####################################################################################"
echo "#                             Running Terraform plan                               #"
echo "####################################################################################"
echo ""
terraform plan -var-file=${parameterfile} ${repo_path}/deploy/terraform/run/${deployment_system}/ > plan_output.log

if ! $new_deployment; then
    if grep "No changes" plan_output.log ; then
echo ""
echo "####################################################################################"
echo "#                             Infrastructure is up to date                         #"
echo "####################################################################################"
echo ""
        rm plan_output.log
        exit 0
    fi
    if ! grep "0 to change, 0 to destroy" plan_output.log ; then
        echo ""
        echo "####################################################################################"
        echo "#                             !!! Risk for Data loss !!!                           #"
        echo "#                    Please run Terraform plan and inspect the output .            #"
        echo "####################################################################################"

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
        echo ""
        echo "####################################################################################"
        echo "#                             Running Terraform apply                              #"
        echo "####################################################################################"
    echo ""

    terraform apply ${approve} -var-file=${parameterfile} ${repo_path}/deploy/terraform/run/${deployment_system}/

fi
