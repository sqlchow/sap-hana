#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/deploy_utils.sh"

function showhelp {
    echo ""
    echo "#########################################################################################"
    echo "#                                                                                       #"
    echo "#                                                                                       #"
    echo "#   This file contains the logic to addd the SPN secrets to the keyvault.               #"
    echo "#                                                                                       #"
    echo "#                                                                                       #"
    echo "#   Usage: set_secret.sh                                                                #"
    echo "#      -e environment name                                                              #"
    echo "#      -r region short name                                                             #"
    echo "#      -v vault name                                                                    #"
    echo "#      -c SPN app id                                                                    #"
    echo "#      -s SPN password                                                                  #"
    echo "#      -t tenant id of SPN                                                              #"
    echo "#      -h Show help                                                                     #"
    echo "#                                                                                       #"
    echo "#   Example:                                                                            #"
    echo "#                                                                                       #"
    echo "#   [REPO-ROOT]deploy/scripts/set_secret.sh \                                           #"
    echo "#      -e PROD  \                                                                       #"
    echo "#      -r weeu  \                                                                       #"
    echo "#      -v prodweeuusrabc  \                                                             #"
    echo "#      -c 11111111-1111-1111-1111-111111111111 \                                        #"
    echo "#      -s SECRETPassword \                                                              #"
    echo "#      -t 222222222-2222-2222-2222-222222222222                                         #"
    echo "#                                                                                       #"
    echo "#########################################################################################"
}


INPUT_ARGUMENTS=$(getopt -n prepare_region -o e:r:v:s:c:p:t:i --longoptions environment:,region:,vault:,subscription:,spn_id:,spn_secret:,tenant_id:,help -- "$@")
VALID_ARGUMENTS=$?

if [ "$VALID_ARGUMENTS" != "0" ]; then
  showhelp
fi

eval set -- "$INPUT_ARGUMENTS"
while :
do
  case "$1" in
    -e | --environment)                        environment="$2"             ; shift 2 ;;
    -r | --region)                             region="$2"                  ; shift 2 ;;
    -v | --vault)                              keyvault="$2"                ; shift 2 ;;
    -s | --subscription)                       subscription="$2"            ; shift 2 ;;
    -c | --spn_id)                             client_id="$2"               ; shift 2 ;;
    -p | --spn_secret)                         client_secret="$2"           ; shift 2 ;;
    -t | --tenant_id)                          tenant_id="$2"               ; shift 2 ;;
    -h | --help)                               showhelp 
                                               exit 3                       ; shift ;;
    --) shift; break ;;
  esac
done

automation_config_directory=~/.sap_deployment_automation/

if [ ! -d "${automation_config_directory}" ]
then
    # No configuration directory exists
    mkdir "${automation_config_directory}"
fi


if [ ! -n "${environment}" ]; then
    read -p "Environment name:"  environment
fi

environment_config_information="${automation_config_directory}""${environment}""${region}"
touch "${environment_config_information}"

if [ ! -d "${automation_config_directory}" ]
then
    # No configuration directory exists
    mkdir "${automation_config_directory}"
else
    touch "${environment_config_information}"
   
fi

if [ ! -n "$subscription" ]; 
then
  load_config_vars "${environment_config_information}" "subscription"
fi

if [ "$workload" != 1 ] ;
then
    load_config_vars "${environment_config_information}" "kvsubscription"
    subscription=${kvsubscription}
fi

if [ ! -n "$keyvault" ]; then
    load_config_vars "${environment_config_information}" "keyvault"
    if [ ! -n "$keyvault" ]; then
        read -p "Keyvault name:"  keyvault
    fi
fi

if [ ! -n "$client_id" ]; then
    load_config_vars "${environment_config_information}" "client_id"
    if [ ! -n "$client_id" ]; then
        read -p "SPN App ID:"  client_id
    fi
fi

if [ ! -n "$client_secret" ]; then
    read -p "SPN App Password:"  client_secret
fi

if [ ! -n "${tenant_id}" ]; then
    load_config_vars "${environment_config_information}" "tenant_id"
    if [ ! -n "${tenant_id}" ]; then
        read -p "SPN Tenant ID:"  tenant_id
    fi
fi

if [ ! -n "$subscription" ]; then
    read -p "SPN Subscription:"  subscription
fi

if [ ! -n "${environment}" ]; then
    read -p "Environment:"  environment
fi

if [ ! -n "${keyvault}" ]; then
    showhelp
    exit -1
fi

if [ ! -n "${client_id}" ]; then
    showhelp
    exit -1
fi

if [ ! -n "$client_secret" ]; then
    showhelp
    exit -1
fi

if [ ! -n "${tenant_id}" ]; then
    showhelp
    exit -1
fi

echo "#########################################################################################"
echo "#                                                                                       #"
echo "#                              Setting the secrets                                      #"
echo "#                                                                                       #"
echo "#########################################################################################"
echo ""

save_config_vars "${environment_config_information}" \
keyvault \
environment \
subscription \
client_id \
tenant_id

secretname="${environment}"-subscription-id

az keyvault secret set --name "${secretname}" --vault-name "${keyvault}" --value "${subscription}"  > stdout.az 2>&1
result=$(grep "ERROR: The user, group or application" stdout.az)

if [ -n "${result}" ]; then
    upn=$(az account show | grep name | grep @ | cut -d: -f2 | cut -d, -f1 | tr -d \" | xargs)
    az keyvault set-policy -n "${keyvault}" --secret-permissions get list recover restore set --upn "${upn}"
fi

az keyvault secret set --name "${secretname}" --vault-name "${keyvault}" --value "${subscription}"  > stdout.az 2>&1

result=$(grep "ERROR: The user, group or application" stdout.az)

if [ -n "${result}" ]; then
    echo "#########################################################################################"
    echo "#                                                                                       #"
    echo "#          No access to add the secrets in the" "${keyvault}" "keyvault             #"
    echo "#            Please add an access policy for the account you use                        #"
    echo "#                                                                                       #"
    echo "#########################################################################################"
    echo ""
    rm stdout.az
    exit -1
fi

result=$(grep "The Vault may not exist" stdout.az)
if [ -n "${result}" ]; then
    printf -v val "%-20.20s could not be found!" "$keyvault"
    echo "#########################################################################################"
    echo "#                                                                                       #"
    echo "#                      Keyvault" "${val}" "               #"
    echo "#                                                                                       #"
    echo "#########################################################################################"
    echo ""
    rm stdout.az
    exit -1
fi



secretname="${environment}"-client-id
az keyvault secret set --name "${secretname}" --vault-name "${keyvault}" --value "${client_id}"

secretname="${environment}"-tenant-id
az keyvault secret set --name "${secretname}" --vault-name "${keyvault}" --value "${tenant_id}"

secretname="${environment}"-client-secret
az keyvault secret set --name "${secretname}" --vault-name "${keyvault}" --value "${client_secret}"


