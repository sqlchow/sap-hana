#!/bin/bash

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
    echo "#      -v vault name                                                                    #"
    echo "#      -c SPN app id                                                                    #"
    echo "#      -s SPN password                                                                  #"
    echo "#      -t tenant of                                                                     #"
    echo "#v -i true/false. If true runs in interactive mode prompting for input                  #"
    echo "# -h Show help                                                                          #"
    echo "#                                                                                       #" 
    echo "#   Example:                                                                            #" 
    echo "#                                                                                       #" 
    echo "#   [REPO-ROOT]deploy/scripts/set_secret.sh \                                           #"
	echo "#      -e PROD  \                                                                       #"
	echo "#      -v prodweeuusrabc  \                                                             #"
	echo "#      -c 11111111-1111-1111-1111-111111111111 \                                        #"
	echo "#      -s SECRETPassword \                                                              #" 
	echo "#      -t 222222222-2222-2222-2222-222222222222                                         #"
    echo "#                                                                                       #" 
    echo "#########################################################################################"
}

while getopts ":e:c:s:t:h:v:x:i" option; do
    case "${option}" in
        e) environment=${OPTARG};;
        c) client_id=${OPTARG};;
        s) client_secret=${OPTARG};;
        t) tenant=${OPTARG};;
        v) vaultname=${OPTARG};;
        i) interactive=true;;
        h) showhelp
           exit 3
           ;;
        ?) echo "Invalid option: -${OPTARG}."
           exit 2
           ;; 
            
    esac
done

if [ $interactive == true ]; then
    read -p "Environment name:"  environment
    read -p "Keyvault name:"  vaultname
    read -p "SPN App ID:"  client_id
    read -p "SPN App Password:"  client_secret
    read -p "SPN Tenant ID:"  tenant
    
fi

if [ ! -n "$ARM_SUBSCRIPTION_ID" ]; then
    echo ""
    echo "####################################################################################"
    echo "# Missing environment variables (ARM_SUBSCRIPTION_ID)!!!                           #"
    echo "# Please export the folloing variables:                                            #"
    echo "# ARM_SUBSCRIPTION_ID (subscription containing the state file storage account)     #"
    echo "####################################################################################"
    exit 1
fi

if [ ! -n "$environment" ]; then
    echo ""
    echo "#########################################################################################"
    echo "#                                                                                       #"
    echo "#   Missing environment!!!                                                              #"
    echo "#                                                                                       #"
    echo "#   Usage: set_secrets.sh                                                               #"
    echo "#     -e environment name <---                                                          #"
    echo "#     -v vault name                                                                     #"
    echo "#     -c SPN app id                                                                     #"
    echo "#     -s SPN password                                                                   #"
    echo "#     -t tenant id                                                                      #"
    echo "#     -i true/false. If true then prompts for input                                     #"
    echo "#     -h Show help                                                                      #"
    echo "#                                                                                       #"
    echo "#########################################################################################"
    exit 2
fi

if [ ! -n "$vaultname" ]; then
    echo ""
    echo "#########################################################################################"
    echo "#                                                                                       #"
    echo "#   Missing vault name!!!                                                               #"
    echo "#                                                                                       #"
    echo "#   Usage: set_secrets.sh                                                               #"
    echo "#     -e environment name    -                                                          #"
    echo "#     -v vault name <--                                                                 #"
    echo "#     -c SPN app id                                                                     #"
    echo "#     -s SPN password                                                                   #"
    echo "#     -t tenant id                                                                      #"
    echo "#     -i true/false. If true then prompts for input                                     #"
    echo "#     -h Show help                                                                      #"
    echo "#                                                                                       #"
    echo "#########################################################################################"
    exit 3
fi

if [ ! -n "$client_id" ]; then
    echo ""
    echo "#########################################################################################"
    echo "#                                                                                       #"
    echo "#   Missing SPN App ID                                                                  #"
    echo "#                                                                                       #"
    echo "#   Usage: set_secrets.sh                                                               #"
    echo "#     -e environment name    -                                                          #"
    echo "#     -v vault name                                                                     #"
    echo "#     -c SPN app id <--                                                                 #"
    echo "#     -s SPN password                                                                   #"
    echo "#     -t tenant id                                                                      #"
    echo "#     -i true/false. If true then prompts for input                                     #"
    echo "#     -h Show help                                                                      #"
    echo "#                                                                                       #"
    echo "#########################################################################################"
    exit 4
fi


if [ ! -n "$client_secret" ]; then
    echo ""
    echo "#########################################################################################"
    echo "#                                                                                       #"
    echo "#   Missing SPN password!                                                               #"
    echo "#                                                                                       #"
    echo "#   Usage: set_secrets.sh                                                               #"
    echo "#     -e environment name    -                                                          #"
    echo "#     -v vault name                                                                     #"
    echo "#     -c SPN app id                                                                     #"
    echo "#     -s SPN password <---                                                              #"
    echo "#     -t tenant id                                                                      #"
    echo "#     -i true/false. If true then prompts for input                                     #"
    echo "#     -h Show help                                                                      #"
    echo "#                                                                                       #"
    echo "#########################################################################################"
    exit 5
fi

if [ ! -n "$tenant" ]; then
    echo ""
    echo "#########################################################################################"
    echo "#                                                                                       #"
    echo "#   Missing Tenant ID!                                                                  #"
    echo "#                                                                                       #"
    echo "#   Usage: set_secrets.sh                                                               #"
    echo "#     -e environment name    -                                                          #"
    echo "#     -v vault name                                                                     #"
    echo "#     -c SPN app id                                                                     #"
    echo "#     -s SPN password                                                                   #"
    echo "#     -t tenant id <--                                                                  #"
    echo "#     -i true/false. If true then prompts for input                                     #"
    echo "#     -h Show help                                                                      #"
    echo "#                                                                                       #"
    echo "#########################################################################################"
    exit 6
fi

echo "#########################################################################################"
echo "#                                                                                       #" 
echo "#                              Setting the secrets                                      #"
echo "#                                                                                       #" 
echo "#########################################################################################"
echo ""


az keyvault secret set --name "${environment}-subscription-id" --vault-name "${vaultname}" --value $ARM_SUBSCRIPTION_ID
az keyvault secret set --name "${environment}-client-id"       --vault-name "${vaultname}" --value $client_id
az keyvault secret set --name "${environment}-client-secret"   --vault-name "${vaultname}" --value $client_secret
az keyvault secret set --name "${environment}-tenant-id"       --vault-name "${vaultname}" --value $tenant