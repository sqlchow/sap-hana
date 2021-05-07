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
    
    
}    Write-Host -ForegroundColor green "Remove the" $Type

    $fInfo = Get-ItemProperty -Path $Parameterfile
    if (!$fInfo.Exists ) {
        Write-Error ("File " + $Parameterfile + " does not exist")
        return
    }

    $ParamFullFile = (Get-ItemProperty -Path $Parameterfile -Name Fullname).Fullname


    $CachePath = (Join-Path -Path $Env:APPDATA -ChildPath "terraform.d\plugin-cache")
    if ( -not (Test-Path -Path $CachePath)) {
        New-Item -Path $CachePath -ItemType Directory
    }
    $env:TF_PLUGIN_CACHE_DIR = $CachePath
    $curDir = (Get-Location)
 
    $extra_vars = " "
    if (  (Test-Path -Path "terraform.tfvars")) {
        $extra_vars = " -var-file=" + (Join-Path -Path $curDir -ChildPath "terraform.tfvars")
    }

 
    Add-Content -Path "deployment.log" -Value ("Removing the: " + $Type)
    Add-Content -Path "deployment.log" -Value (Get-Date -Format "yyyy-MM-dd HH:mm")

    $mydocuments = [environment]::getfolderpath("mydocuments")
    $filePath = $mydocuments + "\sap_deployment_automation.ini"
    $iniContent = Get-IniContent -Path $filePath

    $jsonData = Get-Content -Path $Parameterfile | ConvertFrom-Json

    $Environment = $jsonData.infrastructure.environment
    $region = $jsonData.infrastructure.region
    $combined = $Environment + $region

    $key = $fInfo.Name.replace(".json", ".terraform.tfstate")

    if ($null -eq $iniContent[$combined]) {
        Write-Error "The Terraform state information is not available"

        $saName = Read-Host -Prompt "Please specify the storage account name for the terraform storage account"
        $rID = Get-AzResource -Name $saName
        $rgName = $rID.ResourceGroupName

        $tfstate_resource_id = $rID.ResourceId
        $sub = $tfstate_resource_id.Split("/")[2]

        $Category1 = @{"REMOTE_STATE_RG" = $rgName; "REMOTE_STATE_SA" = $saName; "tfstate_resource_id" = $tfstate_resource_id; STATE_SUBSCRIPTION = $sub }
        $iniContent += @{$combined = $Category1 }
        $changed = $true
    }
    else {
        $deployer_tfstate_key = $iniContent[$combined]["Deployer"]
        $landscape_tfstate_key = $iniContent[$combined]["Landscape"]
    
        $tfstate_resource_id = $iniContent[$combined]["tfstate_resource_id"] 
        $rgName = $iniContent[$combined]["REMOTE_STATE_RG"] 
        $saName = $iniContent[$combined]["REMOTE_STATE_SA"] 
        $sub = $iniContent[$combined]["STATE_SUBSCRIPTION"] 

            
    }

    $ctx= Get-AzContext
    if($null -eq $ctx) {
        Connect-AzAccount  
    }
    
     # Subscription
     $sub = $iniContent[$combined]["STATE_SUBSCRIPTION"]

     if ($null -ne $sub -and "" -ne $sub) {
        Select-AzSubscription -SubscriptionId $sub
     }
     else {
        $sub = $env:ARM_SUBSCRIPTION_ID
     }

     if ($null -eq $saName -or "" -eq $saName) {
        $saName = Read-Host -Prompt "Please specify the storage account name for the terraform storage account"
        $rID = Get-AzResource -Name $saName.Trim()  -ResourceType Microsoft.Storage/storageAccounts
        Write-Host $rID
        $rgName = $rID.ResourceGroupName
        $tfstate_resource_id = $rID.ResourceId
        $sub = $tfstate_resource_id.Split("/")[2]

        $iniContent[$combined]["STATE_SUBSCRIPTION"] = $sub.Trim() 
        $iniContent[$combined]["REMOTE_STATE_RG"] = $rgName
        $iniContent[$combined]["REMOTE_STATE_SA"] = $saName
        $iniContent[$combined]["tfstate_resource_id"] = $tfstate_resource_id
        $changed = $true
        if ($changed) {
            Out-IniFile -InputObject $iniContent -Path $filePath
        }
        $changed = $false

    }
    else {
        $rgName = $iniContent[$combined]["REMOTE_STATE_RG"]
        $tfstate_resource_id = $iniContent[$combined]["tfstate_resource_id"]
    }

    if ($null -eq $tfstate_resource_id -or "" -eq $tfstate_resource_id) {
        
        $rID = Get-AzResource -Name $saName
        $rgName = $rID.ResourceGroupName
        $tfstate_resource_id = $rID.ResourceId
        $sub = $tfstate_resource_id.Split("/")[2]

        $iniContent[$combined]["STATE_SUBSCRIPTION"] = $sub.Trim() 
        $iniContent[$combined]["REMOTE_STATE_RG"] = $rgName
        $iniContent[$combined]["REMOTE_STATE_SA"] = $saName
        $iniContent[$combined]["tfstate_resource_id"] = $tfstate_resource_id
        $changed = $true
        if ($changed) {
            Out-IniFile -InputObject $iniContent -Path $filePath
    Set-SAPSPNSecrets -Environment PROD -VaultName <vaultname> -SPN_id <appId> -SPN_password <clientsecret> -Tenant_id <Tenant_idID> 
        [Parameter(Mandatory = $true)][string]$SPN_password,
        #Tenant_id
        [Parameter(Mandatory = $true)][string]$Tenant_id,

    $combined = $Environment + $region

    if ($null -eq $iniContent[$combined]) {
        $Category1 = @{"subscription" = "" }
        $iniContent += @{$combined = $Category1 }
    }

    if($Workload) {
        Write-Host ("Setting SPN for workload" + "("+ $combined +")")
        $sub = $iniContent[$combined]["subscription"]
    }
    else {
        $sub = $iniContent[$combined]["STATE_SUBSCRIPTION"]
        Write-Host ("Setting SPN for deployer" + "("+ $combined +")")
    }
    if ($null -eq $sub -or "" -eq $sub) {
        $sub = Read-Host -Prompt "Please enter the subscription for the SPN"
        if($Workload) {
            $iniContent[$combined]["subscription"] = $sub
        }
        else {
            $iniContent[$combined]["STATE_SUBSCRIPTION"] = $sub
        }
