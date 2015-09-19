#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r firstLoginUser='nam'

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../libraries/util.bash"

    "${appPath}/../../../cookbooks/jdk/recipes/install.bash"
    "${appPath}/../../../cookbooks/jq/recipes/install.bash"
    "${appPath}/../../../cookbooks/ps1/recipes/install.bash" --users "${firstLoginUser}, $(whoami)"
    "${appPath}/../../../cookbooks/ssh/recipes/install.bash"

    runAptGetUpgrade

    addUserToSudoWithoutPassword "${firstLoginUser}"
    autoSudo "${firstLoginUser}" '.profile'

    setupRepository
    updateRepositoryOnLogin "$(whoami)"

    addUserAuthorizedKey "${firstLoginUser}" "${firstLoginUser}" "$(cat "${appPath}/../files/authorized_keys")"

    cleanUpSystemFolders
    resetLogs
}

main "${@}"