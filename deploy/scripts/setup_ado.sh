#!/bin/bash

function SetupAuthentication {
    if [ ! -n "${ORGANIZATION1}" ] ;then

    read -p "Please provide the Azure DevOps ORGANIZATION name? "  ORGANIZATION
    export ORGANIZATION="${ORGANIZATION}"
    echo "ORGANIZATION="${ORGANIZATION}>>/etc/environment
    fi

    if [ ! -n "${PROJECT1}" ] ;then

    read -p "Please provide the Azure DevOps PROJECT name? "  PROJECT
    export PROJECT="${PROJECT}"
    echo "PROJECT="${PROJECT}>>/etc/environment
    fi

    if [ ! -n "${REPONAME1}" ] ;then

    read -p "Please provide the Azure DevOps repo name? "  REPONAME
    export REPONAME="${REPONAME}"
    echo "REPONAME="${REPONAME}>>/etc/environment
    fi


    if [ ! -n "${PAT1}" ] ;then

    read -p "Please provide your Azure DevOps PAT? "  PAT
    export PAT="${PAT}"
    B64_PAT=$(printf "%s"":$PAT" | base64)
    export B64_PAT="${B64_PAT}"
    echo "B64_PAT="${B64_PAT}>>/etc/environment
    echo "PAT="${PAT}>>/etc/environment
    fi

}

read -p "Register the environment variables? Y/N "  ans
answer=${ans^^}
if [ $answer == 'Y' ]; then
    SetupAuthentication
fi



cd /home/azureadm/Azure_SAP_Automated_Deployment || exit

git -c http.extraHeader="Authorization: Basic ${B64_PAT}" clone https://dev.azure.com/$ORGANIZATION/$PROJECT/_git/$REPONAME WORKSPACES
