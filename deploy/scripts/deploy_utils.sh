#!/bin/bash

#########################################################################
# Helper utilities
#
# Acknowledgements: Fergal Mc Carthy, SUSE
#########################################################################

function save_config_var() {
    local var_name=$1 var_file=$2
    sed -i -e "" -e /$var_name/d "${var_file}"
    echo "${var_name}=${!var_name}" >> "${var_file}"
}

function save_config_vars() {
    local var_file="${1}" var_name
       
    shift  # shift params 1 place to remove var_file value from front of list
    
    for var_name  # iterate over function params
    do
        sed -i -e "" -e /${var_name}/d "${var_file}"
        echo "${var_name}=${!var_name}" >> "${var_file}"
        
    done
}

function load_config_vars() {
    local var_file="${1}" 
    local var_name="${2}" 
    local var_value
    
    for var_name
    do
        if [ -f "${var_file}" ]
        then
            var_value="$(grep -m1 "^${var_name}=" "${var_file}" | cut -d'=' -f2 | tr -d '"')"
        fi
        
        [[ -z "${var_value}" ]] && continue #switch to compound command `[[` instead of `[`
        
        typeset -g "${var_name}"  # declare the specified variable as global
        
        eval "${var_name}='${var_value}'"  # set the variable in global context
    done
}


function init() {
    local automation_config_directory="${1}"
    local generic_config_information="${2}"
    local app_config_information="${3}"
    
    if [ ! -d "${automation_config_directory}" ]
    then
        # No configuration directory exists
        mkdir "${automation_config_directory}"
        touch "${app_config_information}"
        touch "${generic_config_information}"
        if [ -n "${DEPLOYMENT_REPO_PATH}" ]; then
            # Store repo path in ~/.sap_deployment_automation/config
            save_config_var "DEPLOYMENT_REPO_PATH" "${generic_config_information}"
        fi
        if [ -n "$ARM_SUBSCRIPTION_ID" ]; then
            # Store ARM Subscription info in ~/.sap_deployment_automation
            save_config_var "ARM_SUBSCRIPTION_ID" "${app_config_information}"
        fi
        
    else
        touch "${generic_config_information}"
        touch "${app_config_information}"
        load_config_vars "${generic_config_information}" "DEPLOYMENT_REPO_PATH"
        load_config_vars "${app_config_information}" "ARM_SUBSCRIPTION_ID"
    fi
    
    
}

function error_msg {
    echo "Error!!! ${@}"
}

function fail_if_null {
    local var_name="${1}"

    # return immeditaely if no action required
    if [ "${!var_name}" != "null" ]; then
        return
    fi

    shift 1

    if (( $# > 0 )); then
        error_msg "${@}"
    else
        error_msg "Got a null value for '${var_name}'"
    fi

    exit 1
}

function get_and_store_sa_details {
    local REMOTE_STATE_SA="${1}"
    local config_file_name="${2}"

    save_config_vars "${config_file_name}" REMOTE_STATE_SA
    tfstate_resource_id=$(az resource list --name "${REMOTE_STATE_SA}" --resource-type Microsoft.Storage/storageAccounts | jq --raw-output '.[0].id')
    fail_if_null tfstate_resource_id
    STATE_SUBSCRIPTION=$(echo $tfstate_resource_id | cut -d/ -f3 | tr -d \" | xargs)
    REMOTE_STATE_RG=$(echo $tfstate_resource_id | cut -d/ -f5 | tr -d \" | xargs)

    
    save_config_vars "${config_file_name}" \
        REMOTE_STATE_RG \
        tfstate_resource_id \
        STATE_SUBSCRIPTION

}

# /*---------------------------------------------------------------------------8
# |                                                                            |
# |            Discover the executing user and client                          |
# |                                                                            |
# +------------------------------------4--------------------------------------*/
function set_azure_cloud_environment_variables() {
    #Description
    # Find the cloud environment where we are executing.
    # This is included for future use.
    
    echo "[set_azure_cloud_environment_variables]: Identifying the executing cloud environment"    
    
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
    else
        echo "[set_azure_cloud_environment_variables]: Unable to determine the Azure cloud environment"
    fi
}

function set_executing_user_environment_variables() {
    
    local exec_user_type
    local az_user_name
    local az_user_obj_id
    local az_tenant_id
    
    echo "[get_executing_user_and_client]: Identifying the executing user and client"
    
    set_azure_cloud_environment_variables

    
    exec_user_type=$(az account show | jq -r .user.type)
    
    if [ "${exec_user_type}" == "user" ]; then
        
        echo "[get_executing_user_and_client]: Identified login type as 'user'"

        unset ARM_TENANT_ID
        unset ARM_SUBSCRIPTION_ID
        unset ARM_CLIENT_ID
        unset ARM_CLIENT_SECRET
        unset SCRIPT_TF_aad_app_object_id

        az_tenant_id=$(az account show -o json | jq -r .tenantId)
        az_user_obj_id=$(az ad signed-in-user show --query objectId -o tsv)
        az_user_name=$(az ad signed-in-user show --query userPrincipalName -o tsv)

        echo "[get_executing_user_and_client]: logged in user objectID: ${az_user_obj_id} (${az_user_name})"
        echo "[get_executing_user_and_client]: Initializing state with user: ${az_user_name}"
    else
        
        unset az_user_obj_id
        
        #when logged in as a service principal or MSI, username is clientID
        export clientID=$(az account show --query user.name -o tsv)

        #do we need to get details of the service principal?
        if [ "${clientID}" == "null" ]; then
            echo "[get_executing_user_and_client]: unable to identify the executing user and client"
            return 65      #/* data format error */
        fi

        case "${clientID}" in
            "systemAssignedIdentity")
                echo "[get_executing_user_and_client]: logged in using System Assigned Identity"
                ;;
            "userAssignedIdentity")
                echo "[get_executing_user_and_client]: logged in using User Assigned Identity: ($(az account))"
                ;;
            *)
                echo "[get_executing_user_and_client]: unable to identify the executing user and client"
                ;;
        esac

    fi
}