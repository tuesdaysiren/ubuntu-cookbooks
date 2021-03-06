#!/bin/bash -e

function installDependencies()
{
    # Groovy

    if [[ "$(existCommand 'groovy')" = 'false' || ! -d "${JENKINS_GROOVY_INSTALL_FOLDER}" ]]
    then
        "${APP_FOLDER_PATH}/../../groovy/recipes/install.bash" "${JENKINS_GROOVY_INSTALL_FOLDER}"
    fi

    # Tomcat

    if [[ ! -f "${JENKINS_TOMCAT_INSTALL_FOLDER}/bin/catalina.sh" ]]
    then
        "${APP_FOLDER_PATH}/../../tomcat/recipes/install.bash" "${JENKINS_TOMCAT_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Set Install Folder Path

    local -r jenkinsDefaultInstallFolder="$(getUserHomeFolder "${JENKINS_USER_NAME}")/.jenkins"

    if [[ "$(isEmptyString "${JENKINS_INSTALL_FOLDER}")" = 'true' ]]
    then
        JENKINS_INSTALL_FOLDER="${jenkinsDefaultInstallFolder}"
    fi

    # Clean Up

    jenkinsMasterWARAppCleanUp

    rm -f -r "${jenkinsDefaultInstallFolder}" "${JENKINS_INSTALL_FOLDER}"

    # Create Non-Default Jenkins Home

    if [[ "${JENKINS_INSTALL_FOLDER}" != "${jenkinsDefaultInstallFolder}" ]]
    then
        initializeFolder "${JENKINS_INSTALL_FOLDER}"
        ln -f -s "${JENKINS_INSTALL_FOLDER}" "${jenkinsDefaultInstallFolder}"
        chown -R "${JENKINS_USER_NAME}:${JENKINS_GROUP_NAME}" "${jenkinsDefaultInstallFolder}" "${JENKINS_INSTALL_FOLDER}"
    fi

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${JENKINS_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/jenkins.sh.profile" '/etc/profile.d/jenkins.sh' "${profileConfigData[@]}"

    # Config Cron

    local -r cronConfigData=(
        '__USER_NAME__' "${JENKINS_USER_NAME}"
        '__GROUP_NAME__' "${JENKINS_GROUP_NAME}"
        '__INSTALL_FOLDER__' "${JENKINS_INSTALL_FOLDER}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/jenkins.cron" '/etc/cron.daily/jenkins' "${cronConfigData[@]}"
    chmod 755 '/etc/cron.daily/jenkins'

    # Install

    jenkinsMasterDownloadWARApp
    jenkinsMasterDisplayVersion
    jenkinsMasterRefreshUpdateCenter
    jenkinsMasterInstallPlugins
    jenkinsMasterUpdatePlugins
    jenkinsMasterSafeRestart
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/master.bash"
    source "${APP_FOLDER_PATH}/../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MASTER JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"