#!/bin/bash

function SetupAuthentication {
    local organization="${1}"
    local project="${2}"
    local repoName="${3}"
    local userName="${4}"
    local PAT="${4}" 

    # convert the Personal Access Token to a Base64 encoded string
    B64Pat=$(echo $PAT | base64)

    # store the extra header for git to use
    git config --global --add http.https://$userName@dev.azure.com/$organization/$project/_git/$repoName.extraHeader "AUTHORIZATION: Basic $B64Pat"
}

read -p "Please provide the Azure DevOps organization name? "  organization
read -p "Please provide the Azure DevOps project name? "  project
read -p "Please provide the Azure DevOps repo name? "  repoName
read -p "Please provide your Azure DevOps user name? "  userName
read -p "Please provide your Azure DevOps PAT? "  PAT

SetupAuthentication $organization $project $repoName $userName $PAT

cd ~/Azure_SAP_Automated_Deployment

B64_PAT=$(printf "%s"":$PAT" | base64)
export B64_PAT=$B64_PAT
git -c http.extraHeader="Authorization: Basic ${B64_PAT}" clone https://dev.azure.com/$organization/$project/_git/$repoName WORKSPACES
