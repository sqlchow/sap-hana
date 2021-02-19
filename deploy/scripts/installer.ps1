function New-System {
    <#
    .SYNOPSIS
        Bootstrap a new system

    .DESCRIPTION
        Bootstrap a new system

    .PARAMETER Parameterfile
        This is the parameter file for the system

    .EXAMPLE 

    #
    #
    # Import the module
    Import-Module "SAPDeploymentUtilities.psd1"
    New-System -Parameterfile .\PROD-WEEU-SAP00-ZZZ.json -Type sap_system

    .EXAMPLE 

    #
    #
    # Import the module
    Import-Module "SAPDeploymentUtilities.psd1"
    New-System -Parameterfile .\PROD-WEEU-SAP_LIBRARY.json -Type sap_library

    
.LINK
    https://github.com/Azure/sap-hana

.NOTES
    v0.1 - Initial version

.

    #>
    <#
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.
#>
    [cmdletbinding()]
    param(
        #Parameter file
        [Parameter(Mandatory = $true)][string]$Parameterfile ,
        [Parameter(Mandatory = $true)][string]$Type
    )

    Write-Host -ForegroundColor green ""
    Write-Host -ForegroundColor green "Deploying the "+ $Type

    $mydocuments = [environment]::getfolderpath("mydocuments")
    $filePath = $mydocuments + "\sap_deployment_automation.ini"
    $iniContent = Get-IniContent $filePath

    [IO.FileInfo] $fInfo = $Parameterfile
    $environmentname = ($fInfo.Name -split "-")[0]
    $region = ($fInfo.Name -split "-")[1]
    $combined = $environmentname + $region
    Write-Host $combined

    $key = $fInfo.Name.replace(".json", ".terraform.tfstate")
    $deployer_tfstate_key= $iniContent[$combined]["Deployer"]
    $landscape_tfstate_key= $iniContent[$combined]["Landscape"]

    $rgName = $iniContent[$environmentname]["REMOTE_STATE_RG"] 
    $saName = $iniContent[$environmentname]["REMOTE_STATE_SA"] 
    $tfstate_resource_id = $iniContent[$environmentname]["tfstate_resource_id"] 

    # Subscription
    $sub = $iniContent[$environmentname]["subscription"] 
    $repo = $iniContent["Common"]["repo"]
    $changed = $false

    if ($null -eq $sub -or "" -eq $sub) {
        $sub = Read-Host -Prompt "Please enter the subscription"
        $iniContent[$environmentname]["Subscription"] = $sub
        $changed = $true
    }

    if ($null -eq $repo -or "" -eq $repo) {
        $repo = Read-Host -Prompt "Please enter the subscription"
        $iniContent["Common"]["repo"] = $repo
        $changed = $true
    }

    if ($changed) {
        $iniContent | Out-IniFile -Force $filePath
    }

    $terraform_module_directory = $repo + "\deploy\terraform\run\" + $Type

    Write-Host -ForegroundColor green "Initializing Terraform"

    if (Test-Path ".terraform" -PathType Container) {
        $ans = Read-Host -Prompt ".terraform already exists, do you want to continue Y/N?"

        if ("Y" -ne $ans) {
            exit 0
        }
        else {
            $Command = " init -upgrade=true -reconfigure --backend-config ""subscription_id=" + $sub + """" +
            "--backend-config ""resource_group_name=" + $rgName + """" +
            "--backend-config ""storage_account_name=" + $saName + """" +
            "--backend-config ""container_name=tfstate""" +
            "--backend-config ""key=" + $key + """ " +
            $terraform_module_directory
        }
    }
    else {
        $Command = " init -upgrade=true --backend-config ""subscription_id=" + $sub + """" +
        "--backend-config ""resource_group_name=" + $rgName + """" +
        "--backend-config ""storage_account_name=" + $saName + """" +
        "--backend-config ""container_name=tfstate""" +
        "--backend-config ""key=" + $key + """ " +
        $terraform_module_directory
    }

    $Cmd = "terraform $Command"
    & ([ScriptBlock]::Create($Cmd)) 
    if ($LASTEXITCODE -ne 0) {
        throw "Error executing command: $Cmd"
    }

    Write-Host -ForegroundColor green "Running plan"
    if ($Type -ne "sap_deployer") {
        $tfstate_parameter = " -var tfstate_resource_id=" + $tfstate_resource_id
    }

    if ($Type -eq "sap_landscape") {
        $tfstate_parameter = " -var tfstate_resource_id=" + $tfstate_resource_id
        $deployer_tfstate_key_parameter = " -var deployer_tfstate_key=" + $deployer_tfstate_key
    }

    if ($Type -eq "sap_library") {
        $tfstate_parameter = " -var tfstate_resource_id=" + $tfstate_resource_id
        $deployer_tfstate_key_parameter = " -var deployer_tfstate_key=" + $deployer_tfstate_key
    }


    if ($Type -eq "sap_system") {
        $tfstate_parameter = " -var tfstate_resource_id=" + $tfstate_resource_id
        $deployer_tfstate_key_parameter = " -var deployer_tfstate_key=" + $deployer_tfstate_key
        $landscape_tfstate_key_parameter = " -var landscape_tfstate_key=" + $landscape_tfstate_key
    }


    $Command = " plan -var-file " + $Parameterfile + $tfstate_parameter + $landscape_tfstate_key_parameter + $deployer_tfstate_key_parameter + " " + $terraform_module_directory

    $Cmd = "terraform $Command"
    & ([ScriptBlock]::Create($Cmd)) 
    if ($LASTEXITCODE -ne 0) {
        throw "Error executing command: $Cmd"
    }

    Write-Host -ForegroundColor green "Running apply"
    $Command = " apply -var-file " + $Parameterfile + $tfstate_parameter + $landscape_tfstate_key_parameter + $deployer_tfstate_key_parameter + " " + $terraform_module_directory

    $Cmd = "terraform $Command"
    & ([ScriptBlock]::Create($Cmd))  
    if ($LASTEXITCODE -ne 0) {
        throw "Error executing command: $Cmd"
    }

    New-Item -Path . -Name "backend.tf" -ItemType "file" -Value "terraform {`n  backend ""azurerm"" {}`n}" -Force

    if ("sap_deployer" -eq $Type) {

        $Command = " output deployer_kv_user_name"

        $Cmd = "terraform $Command"
        $kvName = & ([ScriptBlock]::Create($Cmd)) | Out-String 
        if ($LASTEXITCODE -ne 0) {
            throw "Error executing command: $Cmd"
        }

        $iniContent[$environmentname]["Vault"] = $kvName
        $iniContent | Out-IniFile -Force $filePath
    }


}