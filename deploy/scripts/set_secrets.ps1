<#

.SYNOPSIS
    Provide the SPN secrets and store them in keyvault 

.DESCRIPTION
    The script saves the SPN credentials in the key vault.


.EXAMPLE
    ./Save-Secrets.ps1 

.LI

.NOTES
    v0.1 - Initial version

#>
<#
Copyright (c) Microsoft Corporation.
Licensed under the MIT license.
#>

function Get-IniContent ($filePath)
{
    $ini = @{}
    switch -regex -file $FilePath
    {
        “^\[(.+)\]” # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        “^(;.*)$” # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = “Comment” + $CommentCount
            $ini[$section][$name] = $value
        }
        “(.+?)\s*=(.*)” # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

function Out-IniFile($InputObject, $FilePath)
{
    $outFile = New-Item -ItemType file -Path $Filepath
    foreach ($i in $InputObject.keys)
    {
        if (!($($InputObject[$i].GetType().Name) -eq “Hashtable”))
        {
            #No Sections
            Add-Content -Path $outFile -Value “$i=$($InputObject[$i])”
        } else {
            #Sections
            Add-Content -Path $outFile -Value “[$i]”
            Foreach ($j in ($InputObject[$i].keys | Sort-Object))
            {
                if ($j -match “^Comment[\d]+”) {
                    Add-Content -Path $outFile -Value “$($InputObject[$i][$j])”
                } else {
                    Add-Content -Path $outFile -Value “$j=$($InputObject[$i][$j])”
                }

            }
            Add-Content -Path $outFile -Value “”
        }
    }
}

#Requires -Modules Az.Compute
#Requires -Version 5.1
param(
    #Environment name
    [Parameter(Mandatory=$true)][string]$Environment,
    #Keyvault name
    [Parameter(Mandatory=$true)][string]$VaultName,
    #SPN App ID
    [Parameter(Mandatory=$true)][string]$client_id,
    #SPN App secret
    [Parameter(Mandatory=$true)][string]$client_secret,
    #Tenant
    [Parameter(Mandatory=$true)][string]$tenant,
    #Deployer parameter name
    [Parameter(Mandatory=$true)][string]$deployer_parameter_name

)


Write-Host -ForegroundColor green ""
Write-Host -ForegroundColor green "Saving the secrets"

$deployer_parameter_ini -replace ".json", ".ini"

$iniContent = Get-IniContent ".\test.ini"




