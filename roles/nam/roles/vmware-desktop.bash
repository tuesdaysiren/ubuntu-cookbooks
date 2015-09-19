#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r firstLoginUser='nam'

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../libraries/util.bash"

    "${appPath}/../../../cookbooks/essential/recipes/install.bash"
    "${appPath}/../../../cookbooks/jdk/recipes/install.bash"
    "${appPath}/../../../cookbooks/jq/recipes/install.bash"
    "${appPath}/../../../cookbooks/ps1/recipes/install.bash"
    "${appPath}/../../../cookbooks/ps1/recipes/install.bash" --profile-file-name '.bashrc' --users "${firstLoginUser}"
    "${appPath}/../../../cookbooks/ssh/recipes/install.bash"
    "${appPath}/../../../cookbooks/vim/recipes/install.bash"
    "${appPath}/../../../cookbooks/vmware-tools/recipes/install.bash"

    addUserToSudoWithoutPassword "${firstLoginUser}"
    autoSudo "${firstLoginUser}" '.bashrc'

    setupRepository
    updateRepositoryOnLogin "$(whoami)"

    addUserAuthorizedKey "${firstLoginUser}" "${firstLoginUser}" "$(cat "${appPath}/../files/authorized_keys")"

    cleanUpSystemFolders
    resetLogs
}

main "${@}"