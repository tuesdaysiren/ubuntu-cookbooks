#!/bin/bash -e

function extend()
{
    local -r disk="${1}"
    local -r mountOn="${2}"

    if [[ "$(existDisk "${disk}")" = 'true' ]]
    then
        if [[ "$(existDiskMount "${disk}${MOUNT_HD_PARTITION_NUMBER}" "${mountOn}")" = 'false' ]]
        then
            rm -f -r "${mountOn}"
            "$(dirname "${BASH_SOURCE[0]}")/install.bash" "${disk}" "${mountOn}"
        else
            header "EXTENDING '${mountOn}' PARTITION"
            info "Already mounted '${disk}${MOUNT_HD_PARTITION_NUMBER}' to '${mountOn}'\n"
            df -h -T
        fi
    else
        header "EXTENDING '${mountOn}' PARTITION"
        info "Extended volume '${disk}' not found"
    fi
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'EXTENDING MOUNT-HD'

    extend "${@}"
    installCleanUp
}

main "${@}"