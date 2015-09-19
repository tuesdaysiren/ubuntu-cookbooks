#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../../../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../../../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../attributes/default.bash"

    # Clean Up

    resetLogs

    # Extend HD

    "${appPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_OPS_DISK}" "${CCMUI_OPS_MOUNT_ON}"

    # Install Apps

    "${appPath}/../../../../../../essential.bash" 'ops.ccmui.adobe.com'
    "${appPath}/../../../../../../../cookbooks/mongodb/recipes/install.bash"
    "${appPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CCMUI_OPS_NODE_JS_VERSION}" "${CCMUI_OPS_NODE_JS_INSTALL_FOLDER}"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/authorized_keys")"
    addUserSSHKnownHost "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/known_hosts")"

    configUserGIT "$(whoami)" "${CCMUI_OPS_GIT_USER_NAME}" "${CCMUI_OPS_GIT_USER_EMAIL}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "$(whoami)"
}

main "${@}"