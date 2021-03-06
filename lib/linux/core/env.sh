#!/usr/bin/env bash

#set -x

HERE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Bootstrap (we use this command to bootstrap the environment, so we have to load its config manually)

_ENV_PROPS_PROJECT_PATH="conf/linux/core/env.properties"

case "${GEOFFREY_MODE:-online}" in
  offline)
    HERE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    source "${HERE}/../../../${_ENV_PROPS_PROJECT_PATH}"
  ;;
  online)
    curl -L -o /tmp/env.properties "https://raw.githubusercontent.com/cloudbees/support-required-data-geoffrey/${GEOFFREY_REMOTE_BRANCH:-master}/conf/linux/core/env.properties" 2>/dev/null
    source /tmp/env.properties

    # Install/Update local copy
    _REMOTE_ZIP="${HOME}/${GEOFFREY_REMOTE_BRANCH:-master}.zip"
    curl -L -o "${_REMOTE_ZIP}" "https://github.com/cloudbees/support-required-data-geoffrey/archive/${GEOFFREY_REMOTE_BRANCH:-master}.zip" 2>/dev/null
    rm -rf /tmp/support-required-data-geoffrey-${GEOFFREY_REMOTE_BRANCH:-master}
    rm -rf "${GEOFFREY_HOME:-${HOME}/geoffrey}"
    unzip -qq "${_REMOTE_ZIP}" -d /tmp
    mv /tmp/support-required-data-geoffrey-${GEOFFREY_REMOTE_BRANCH:-master} "${GEOFFREY_HOME:-${HOME}/geoffrey}"
    mkdir "${GEOFFREY_HOME:-${HOME}/geoffrey}/logs"
  ;;
  *)
    echo "UNKNOWN GEOFFREY_MODE: ${GEOFFREY_MODE}" && exit 1
esac

GEOFFREY_APPLICATION_LIST=($(ls -1 ${GEOFFREY_HOME:-${HOME}/geoffrey}/lib/linux/application/ | sed -e 's/\..*$//' | tr '\r\n' ' '))
GEOFFREY_CORE_APPLICATION_LIST=($(ls -1 ${GEOFFREY_HOME:-${HOME}/geoffrey}/lib/linux/core/ | sed -e 's/\..*$//' | tr '\r\n' ' '))
GEOFFREY_DEVELOPMENT_APPLICATION_LIST=($(ls -1 ${GEOFFREY_HOME:-${HOME}/geoffrey}/lib/linux/development/ | sed -e 's/\..*$//' | tr '\r\n' ' '))

# Load overrides

source ${GEOFFREY_CONF_FILE} 2>/dev/null # Don't care if it doesn't exist