#!/usr/bin/env bash

HERE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Bootstrap (we use this command to bootstrap the environment, so we have to load its config manually)

_ENV_PROPS_PROJECT_PATH="conf/linux/core/env.properties"

case "${GEOFFREY_MODE}" in
  offline)
    HERE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    source "${HERE}/../../../${_ENV_PROPS_PROJECT_PATH}"
  ;;
  online)
    curl "https://github.com/cloudbees/support-required-data-geoffrey/raw/${GEOFFREY_REMOTE_BRANCH:-master}/${_ENV_PROPS_PROJECT_PATH}" | xargs source

    # Install/Update local copy
    _MASTER_ZIP="${HOME}/${GEOFFREY_REMOTE_BRANCH:-master}.zip"
    mkdir -p "${GEOFFREY_HOME}" && curl -L -o "${_MASTER_ZIP}" "${GEOFFREY_REMOTE_BASE_URL}/archive/${GEOFFREY_REMOTE_BRANCH:-master}.zip" && unzip "${_MASTER_ZIP}" -d "${GEOFFREY_HOME}"
  ;;
  *)
    echo "UNKNOWN GEOFFREY_MODE: ${GEOFFREY_MODE}" && exit 1
esac

GEOFFREY_APPLICATION_LIST=($(ls -1 ${HERE}/../../../lib/linux/application/ | sed -e 's/\..*$//' | tr '\r\n' ' '))
GEOFFREY_CORE_APPLICATION_LIST=($(ls -1 ${HERE}/../../../lib/linux/core/ | sed -e 's/\..*$//' | tr '\r\n' ' '))
GEOFFREY_DEVELOPMENT_APPLICATION_LIST=($(ls -1 ${HERE}/../../../lib/linux/development/ | sed -e 's/\..*$//' | tr '\r\n' ' '))

# Load overrides

source ${GEOFFREY_CONF_FILE} 2>/dev/null # Don't care if it doesn't exist