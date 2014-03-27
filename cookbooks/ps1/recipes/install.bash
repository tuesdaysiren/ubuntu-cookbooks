#!/bin/bash

function install()
{
    local profileFile="$(getProfileFile)"
    local prompt="export PS1=\"${rootPrompt}\""

    if [[ "$(grep -F "${prompt}" "${profileFile}")" = '' ]]
    then
        echo >> "${profileFile}"
        echo "${prompt}" >> "${profileFile}"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING PS1'

    checkRequireRootUser
    install
}

main "${@}"