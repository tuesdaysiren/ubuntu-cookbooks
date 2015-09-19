#!/bin/bash -e

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

function autoSudo()
{
    local -r userLogin="${1}"
    local -r profileFileName="${2}"

    header 'SETTING UP AUTO SUDO'

    local -r command='sudo su -'

    appendToFileIfNotFound "$(getUserHomeFolder "${userLogin}")/${profileFileName}" "${command}" "${command}" 'false' 'false' 'true'
}

function setupRepository()
{
    local -r repositoryPath="$(getCurrentUserHomeFolder)/git/github.com/gdbtek"

    header 'SETTING UP REPOSITORY'

    mkdir -p "${repositoryPath}"

    if [[ -d "${repositoryPath}/ubuntu-cookbooks" ]]
    then
        cd "${repositoryPath}/ubuntu-cookbooks"
        git pull
    else
        cd "${repositoryPath}"
        git clone 'https://github.com/gdbtek/ubuntu-cookbooks.git'
    fi
}

function updateRepositoryOnLogin()
{
    local -r userLogin="${1}"

    header 'UPDATING REPOSITORY ON LOGIN'

    local -r command='cd ~/git/github.com/gdbtek/ubuntu-cookbooks/cookbooks && git pull'

    appendToFileIfNotFound "$(getProfileFilePath "${userLogin}")" "${command}" "${command}" 'false' 'false' 'true'
}