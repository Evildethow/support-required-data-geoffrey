#!/usr/bin/env bash

#set -x

# Bootstrap

_BASH_PROFILE="${HOME}/.bashrc"
_BOOTSTRAP_PROJECT_PATH="lib/linux/core/env.sh"

case "${GEOFFREY_MODE:-online}" in
  offline)
    HERE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    source "${HERE}/${_BOOTSTRAP_PROJECT_PATH}"
  ;;
  online)
    GEOFFREY_MODE=online
    curl -L -o /tmp/env.sh "https://raw.githubusercontent.com/cloudbees/support-required-data-geoffrey/${GEOFFREY_REMOTE_BRANCH:-master}/lib/linux/core/env.sh" 2>/dev/null
    chmod +x /tmp/env.sh && . /tmp/env.sh
  ;;
  *)
    echo "UNKNOWN GEOFFREY_MODE: ${GEOFFREY_MODE}" && exit 1
esac


# Install

if [ ! -f "${GEOFFREY_INSTALL_MARKER}" ]; then
    chmod +x "${GEOFFREY_EXEC_FILE}" 2>/dev/null
    printf "\n\n# Geoffrey\n" > "${GEOFFREY_CONF_FILE}" # Create local properties override files
    printf "export PATH=${PATH}:${GEOFFREY_BIN}\n\n" > "${GEOFFREY_CONF_FILE}" # Add geoffrey to the PATH
    echo "${PATH}" | grep -q "${GEOFFREY_BIN}" || printf "\n\nsource ${GEOFFREY_CONF_FILE}\n\n" >> "${_BASH_PROFILE}" # Import geoffrey config
    touch "${GEOFFREY_INSTALL_MARKER}"
fi
