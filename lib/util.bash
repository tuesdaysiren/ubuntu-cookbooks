#!/bin/bash

function header
{
    echo -e "\n\033[1;33m>>>>>>>>>> \033[1;4;35m${1}\033[0m \033[1;33m<<<<<<<<<<\033[0m\n"
}

function error()
{
    echo -e "\033[1;31m${1}\033[0m" 1>&2
}

function fatal()
{
    error "${1}"
    exit 1
}

function trimString()
{
    echo "${1}" | sed -e 's/^ *//g' -e 's/ *$//g'
}

function isEmptyString()
{
    if [[ "$(trimString ${1})" = '' ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function addSystemUser()
{
    local uid="${1}"
    local gid="${2}"

    if [[ "${uid}" = "${gid}" ]]
    then
        adduser --system --no-create-home --disabled-login --disabled-password --group "${gid}" >> /dev/null 2>&1
    else
        addgroup "${gid}" >> /dev/null 2>&1
        adduser --system --no-create-home --disabled-login --disabled-password --ingroup "${gid}" "${uid}" >> /dev/null 2>&1
    fi
}

function checkRequireRootUser
{
    if [[ "$(whoami)" != 'root' ]]
    then
        fatal "ERROR: please run this program as 'root'"
    fi
}

function getFileName()
{
    local fullFileName="$(basename "${1}")"

    echo "${fullFileName%.*}"
}

function displayOpenPorts
{
    header 'LIST OPEN PORTS'

    sleep 5
    lsof -P -i | grep ' (LISTEN)$' | sort
}

function checkPortRequirement
{
    local ports="${@:1}"
    local headerRegex='^COMMAND\s\+PID\s\+USER\s\+FD\s\+TYPE\s\+DEVICE\s\+SIZE\/OFF\s\+NODE\s\+NAME$'
    local status="$(lsof -P -i | grep "\( (LISTEN)$\)\|\(${headerRegex}\)")"
    local open=''

    for port in ${ports}
    do
        local found="$(echo "${status}" | grep ":${port} (LISTEN)$")"

        if [[ "${found}" != '' ]]
        then
            open="${open}\n${found}"
        fi
    done

    if [[ "${open}" != '' ]]
    then
        echo -e  "\033[1;31mFollowing ports are still opened. Make sure you uninstall or stop them before a new installation!\033[0m"
        echo -en "\033[1;34m\n$(echo "${status}" | grep "${headerRegex}")\033[0m"
        echo -e  "\033[1;36m${open}\033[0m\n"
        exit 1
    fi
}

function getProfileFile()
{
    local bashProfileFile="${HOME}/.bash_profile"
    local profileFile="${HOME}/.profile"
    local defaultStartUpFile="${bashProfileFile}"

    if [[ ! -f "${bashProfileFile}" && -f "${profileFile}" ]]
    then
        defaultStartUpFile="${profileFile}"
    fi

    echo "${defaultStartUpFile}"
}

function escapeSearchPattern()
{
    echo "$(echo "${1}" | sed "s@\[@\\\\[@g" | sed "s@\*@\\\\*@g" | sed "s@\%@\\\\%@g")"
}

function safeCopyFile()
{
    local sourceFilePath="${1}"
    local destinationFilePath="${2}"

    safeOpFile 'cp' "${sourceFilePath}" "${destinationFilePath}"
}

function safeMoveFile()
{
    local sourceFilePath="${1}"
    local destinationFilePath="${2}"

    safeOpFile 'mv' "${sourceFilePath}" "${destinationFilePath}"
}

function safeOpFile()
{
    local action="${1}"
    local sourceFilePath="${2}"
    local destinationFilePath="${3}"

    if [[ -f "${sourceFilePath}" ]]
    then
        if [[ -f "${destinationFilePath}" ]]
        then
            mv "${destinationFilePath}" "${destinationFilePath}_$(date +%m%d%Y)_$(date +%H%M%S).BAK"
        fi

        "${action}" "${sourceFilePath}" "${destinationFilePath}"
    fi
}
