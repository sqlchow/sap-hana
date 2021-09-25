#!/bin/bash
# /*---------------------------------------------------------------------------8
# |                                                                            |
# |            Discover the executing user and client                          |
# |                                                                            |
# +------------------------------------4--------------------------------------*/
function is_valid_guid() {
    local guid=$1
    # when valid GUID; 0=true, 1=false
    if [[ $guid =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
        return 0
    else
        return 1
    fi
}

function getEnvVarValue() {
    local varName=$1
    local varValue=$(printenv $varName)
    echo "${varValue}"
}

function checkforExportedEnvVar() {
    local env_var=
    env_var=$(declare -p "$1")
    if [[  -v $1 && $env_var =~ ^declare\ -x ]]; then
        getEnvVarValue "$1"
    else
        echo "__NotExported"
    fi
}

# Check if we are running in CloudShell, we have the following three environment 
# variables: POWERSHELL_DISTRIBUTION_CHANNEL, AZURE_HTTP_USER_AGENT, and 
# AZUREPS_HOST_ENVIRONMENT. We will use the first one to determine if we are
# running in CloudShell.
# Default values for these variables are:
# POWERSHELL_DISTRIBUTION_CHANNEL=CloudShell
# AZURE_HTTP_USER_AGENT=cloud-shell/1.0
# AZUREPS_HOST_ENVIRONMENT=cloud-shell/1.0
function checkIfCloudShell() {
    local isRunInCloudShell=1 # default value is false
    
    if [ "$POWERSHELL_DISTRIBUTION_CHANNEL" == "CloudShell" ]; then
        isRunInCloudShell=0
    fi
    
    return $isRunInCloudShell
}

function set_azure_cloud_environment() {
    #Description
    # Find the cloud environment where we are executing.
    # This is included for future use.

    echo -e "\t\t[set_azure_cloud_environment]: Identifying the executing cloud environment"

    # set the azure cloud environment variables
    local azure_cloud_environment=''

    unset AZURE_ENVIRONMENT

    # check the azure environment in which we are running
    AZURE_ENVIRONMENT=$(az cloud show --query name --output tsv)

    if [ -n "${AZURE_ENVIRONMENT}" ]; then

        case $AZURE_ENVIRONMENT in
        AzureCloud)
            azure_cloud_environment='public'
            ;;
        AzureUSGovernment)
            azure_cloud_environment='usgov'
            ;;
        AzureChinaCloud)
            azure_cloud_environment='china'
            ;;
        AzureGermanCloud)
            azure_cloud_environment='german'
            ;;
        esac

        export AZURE_ENVIRONMENT=${azure_cloud_environment}
        echo -e "\t\t[set_azure_cloud_environment]: Azure cloud environment: ${azure_cloud_environment}"
    else
        echo -e "\t\t[set_azure_cloud_environment]: Unable to determine the Azure cloud environment"
    fi
}

function is_running_in_azureCloudShell() {
    #Description
    # Check if we are running in Azure Cloud Shell
    azureCloudShellIsSetup=1 # default value is false

    echo -e "\t\t[is_running_in_azureCloudShell]: Identifying if we are running in Azure Cloud Shell"
    cloudShellCheck=$(checkIfCloudShell)
    
    if [[ (($cloudShellCheck == 0)) ]]; then 
        echo -e "\t\t[is_running_in_azureCloudShell]: Identified we are running in Azure Cloud Shell"
        echo -e "\t\t[is_running_in_azureCloudShell]: Checking if we have a valid login in Azure Cloud Shell"
        cloudIDUsed=$(az account show | grep "cloudShellID")
        if [ -n "${cloudIDUsed}" ]; then
            echo -e "\t\t[is_running_in_azureCloudShell]: We are using CloudShell MSI and need to run 'az login'"
            echo ""
            echo "#########################################################################################"
            echo "#                                                                                       #"
            echo -e "#     $boldred Please login using your credentials or service principal credentials! $resetformatting      #"
            echo "#                                                                                       #"
            echo "#########################################################################################"
            echo ""
            azureCloudShellIsSetup=67                         #addressee unknown
        else 
            echo -e "\t\t[is_running_in_azureCloudShell]: We have a valid login in Azure Cloud Shell"
            azureCloudShellIsSetup=0                         #we are good to go
        fi
    else
        echo -e "\t\t[is_running_in_azureCloudShell]: We are not running Azure Cloud Shell"
        azureCloudShellIsSetup=1                             #set return to further logic
    fi

    return $azureCloudShellIsSetup
}

function set_executing_user_environment_variables() {

    local az_exec_user_type
    local az_exec_user_name
    local az_user_name
    local az_user_obj_id
    local az_subscription_id
    local az_tenant_id
    local az_client_id
    local az_client_secret  
    
    az_client_secret="$1"
    
    echo -e "\t[set_executing_user_environment_variables]: Identifying the executing user and client"

    set_azure_cloud_environment

    az_exec_user_type=$(az account show | jq -r .user.type)
    az_exec_user_name=$(az account show -o json | jq -r .user.name)
    az_tenant_id=$(az account show -o json | jq -r .tenantId)

    echo -e "\t\t[set_executing_user_environment_variables]: User type: "${az_exec_user_type}""

    # if you are executing as user, we do not want to set any exports to run Terraform
    # else, if you are executing as service principal, we need to export the ARM variables
    if [ "${az_exec_user_type}" == "user" ]; then
        # if you are executing as user, we do not want to set any exports for terraform
        echo -e "\t[set_executing_user_environment_variables]: Identified login type as 'user'"

        unset_executing_user_environment_variables

        az_user_obj_id=$(az ad signed-in-user show --query objectId -o tsv)
        az_user_name=$(az ad signed-in-user show --query userPrincipalName -o tsv)

        # this is the user object id but exporeted as client_id to make it easier to use in TF
        export TF_VAR_arm_client_id=${az_user_obj_id}
        
        echo -e "\t[set_executing_user_environment_variables]: logged in user objectID: ${az_user_obj_id} (${az_user_name})"
        echo -e "\t[set_executing_user_environment_variables]: Initializing state with user: ${az_user_name}"
    else
        # else, if you are executing as service principal, we need to export the ARM variables
        #when logged in as a service principal or MSI, username is clientID
        az_client_id=$(az account show --query user.name -o tsv)
        az_subscription_id=$(az account show --query id -o tsv)

        echo -e "\t\t[set_executing_user_environment_variables]: client id: "${az_client_id}""

        #do we need to get details of the service principal?
        if [ "${az_client_id}" == "null" ]; then
            echo -e "\t[set_executing_user_environment_variables]: unable to identify the executing user and client"
            return 65 #/* data format error */
        fi

        case "${az_client_id}" in
        "systemAssignedIdentity")
            echo -e "\t[set_executing_user_environment_variables]: logged in using '${az_exec_user_type}'"
            echo -e "\t[set_executing_user_environment_variables]: Nothing to do"
            ;;
        "userAssignedIdentity")
            echo -e "\t[set_executing_user_environment_variables]: logged in using User Assigned Identity: '${az_exec_user_type}'"
            echo -e "\t[set_executing_user_environment_variables]: Nothing to do"
            ;;
        *)
            if is_valid_guid "${az_exec_user_name}"; then
                
                az_user_obj_id=$(az ad sp show --id "${az_exec_user_name}" --query objectId -o tsv)
                az_user_name=$(az ad sp show --id "${az_exec_user_name}" --query displayName -o tsv)

                echo -e "\t$(s)[set_executing_user_environment_variables]: Identified login type as 'service principal'"
                echo -e "\t[set_executing_user_environment_variables]: Initializing state with SPN named: ${az_user_name}"

                if [ -z "$az_client_secret" ]; then
                    #do not output the secret to screen
                    stty -echo
                    read -ers -p "        -> Kindly provide SPN Password: " az_client_secret; echo "********"
                    stty echo
                fi

                #export the environment variables
                
                ARM_SUBSCRIPTION_ID=${az_subscription_id}
                ARM_TENANT_ID=${az_tenant_id}
                ARM_CLIENT_ID=${az_exec_user_name}
                if [ "none" != "$az_client_secret" ]; then
                
                  ARM_CLIENT_SECRET=${az_client_secret}
                fi 

                echo -e "\t[set_executing_user_environment_variables]: exporting environment variables"
                export ARM_SUBSCRIPTION_ID
                export ARM_TENANT_ID
                export ARM_CLIENT_ID
                export ARM_CLIENT_SECRET

            else
                echo -e "\t[set_executing_user_environment_variables]: unable to identify the executing user and client"
            fi
            ;;
        esac

    fi
}

function unset_executing_user_environment_variables() {
    echo -e "\t\t[unset_executing_user_environment_variables]: unsetting ARM_* environment variables"
    
    unset ARM_SUBSCRIPTION_ID
    unset ARM_TENANT_ID
    unset ARM_CLIENT_ID
    unset ARM_CLIENT_SECRET

}
# print the script name and function being called
function print_script_name_and_function() {
    echo -e "\t[$(basename "")]: $(basename "$0") $1"
}

#print the function name being executed
#printf maybe instead of echo
#printf "%s\n" "${FUNCNAME[@]}"
#check the AZURE_HTTP_USER_AGENT=cloud-shell/1.0 to identify the cloud shell
#update template to user the following user http://localhost:50342/oauth2/token