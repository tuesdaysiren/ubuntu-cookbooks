#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'ruby')" = 'false' || ! -d "${EC2_AMI_TOOLS_RUBY_INSTALL_FOLDER}" ]]
    then
        "${appPath}/../../ruby/recipes/install.bash" "${EC2_AMI_TOOLS_RUBY_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${EC2_AMI_TOOLS_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${EC2_AMI_TOOLS_DOWNLOAD_URL}" "${EC2_AMI_TOOLS_INSTALL_FOLDER}"

    local -r unzipFolder="$(find "${EC2_AMI_TOOLS_INSTALL_FOLDER}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(wc -l <<< "${unzipFolder}")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    moveFolderContent "${unzipFolder}" "${EC2_AMI_TOOLS_INSTALL_FOLDER}"
    symlinkLocalBin "${EC2_AMI_TOOLS_INSTALL_FOLDER}/bin"
    rm -f -r "${unzipFolder}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${EC2_AMI_TOOLS_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/ec2-ami-tools.sh.profile" '/etc/profile.d/ec2-ami-tools.sh' "${profileConfigData[@]}"

    # Display Version

    info "$("${EC2_AMI_TOOLS_INSTALL_FOLDER}/bin/ec2-ami-tools-version")"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING EC2-AMI-TOOLS'

    installDependencies
    install
    installCleanUp
}

main "${@}"