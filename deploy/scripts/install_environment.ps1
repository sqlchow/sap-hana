<#

.SYNOPSIS
    Deploy a component

.DESCRIPTION
    This script deploys a Terraform module


.EXAMPLE
    ./Installer.ps1 

.LI

.NOTES
    v0.1 - Initial version

#>
<#
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.
#>
Function New-Environment() {
    param(
        #Parameter file
        [Parameter(Mandatory = $true)][string]$DeployerParameterfile,
        [Parameter(Mandatory = $true)][string]$LibraryParameterfile,
        [Parameter(Mandatory = $true)][string]$EnvironmentParameterfile
    )

    Write-Host -ForegroundColor green ""
    Write-Host -ForegroundColor green "Deploying the Full Environment"

    $mydocuments = [environment]::getfolderpath("mydocuments")
    $filePath = $mydocuments + "\sap_deployment_automation.ini"
    $iniContent = Get-IniContent $filePath

    $curDir = Get-Location 
    [IO.DirectoryInfo] $dirInfo = $curDir.ToString()

    $fileDir = $dirInfo.ToString() + $EnvironmentParameterfile
    [IO.FileInfo] $fInfo = $fileDir
    $envkey = $fInfo.Name.replace(".json", ".terraform.tfstate")


    $fileDir = $dirInfo.ToString() + $DeployerParameterfile
    [IO.FileInfo] $fInfo = $fileDir

    $DeployerRelativePath = "..\..\" + $fInfo.Directory.FullName.Replace($dirInfo.ToString() + "\", "")

    $Environment = ($fInfo.Name -split "-")[0]
    $region = ($fInfo.Name -split "-")[1]
    $combined = $Environment + $region

    Write-Host $combined

    $key = $fInfo.Name.replace(".json", ".terraform.tfstate")
    
    $Category1 = @{"Deployer" = $key ;"Landscape" = $envkey}

    $iniContent[$combined] = $Category1
    
    $iniContent | Out-IniFile -Force $filePath

    Set-Location -Path $fInfo.Directory.FullName
    #New-Deployer -Parameterfile $fInfo.Name

    $ans = Read-Host -Prompt "Do you want to enter the Keyvault secrets Y/N?"
    if ("Y" -eq $ans) {
        $vault = $iniContent[$Environment]["Vault"]
        $spnid = $iniContent[$Environment]["Client_id"]
        $Tenant = $iniContent[$Environment]["Tenant"]
        Set-Secrets -Environment $environmentname -VaultName $vault -Client_id $spnid -Tenant $Tenant
    }

    $fileDir = $dirInfo.ToString() + $LibraryParameterfile
    [IO.FileInfo] $fInfo = $fileDir
    Set-Location -Path $fInfo.Directory.FullName

    #New-Library -Parameterfile $fInfo.Name -DeployerFolderRelativePath $DeployerRelativePath

    Set-Location -Path $curDir
    $fileDir = $dirInfo.ToString() + $DeployerParameterfile
    [IO.FileInfo] $fInfo = $fileDir
    Set-Location -Path $fInfo.Directory.FullName

    #New-System -Parameterfile $fInfo.Name -Type "sap_deployer"

    Set-Location -Path $curDir

    $fileDir = $dirInfo.ToString() + $LibraryParameterfile
    [IO.FileInfo] $fInfo = $fileDir
    Set-Location -Path $fInfo.Directory.FullName

    New-System -Parameterfile $fInfo.Name -Type "sap_library"

    Set-Location -Path $curDir

    $fileDir = $dirInfo.ToString() + $EnvironmentParameterfile
    [IO.FileInfo] $fInfo = $fileDir
    Set-Location -Path $fInfo.Directory.FullName

    New-System -Parameterfile $fInfo.Name -Type "sap_landscape"


}