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
    curl "https://github.com/cloudbees/support-required-data-geoffrey/raw/master/${GEOFFREY_REMOTE_BRANCH:-master}/${_BOOTSTRAP_PROJECT_PATH}" | xargs source
    curl -L -o "${GEOFFREY_EXEC_FILE}" "${GEOFFREY_REMOTE_REPO}/bin/linux/geoffrey"
  ;;
  *)
    echo "UNKNOWN GEOFFREY_MODE: ${GEOFFREY_MODE}" && exit 1
esac


# Install

if [ ! -f "${GEOFFREY_INSTALL_MARKER}" ]; then
    chmod +x "${GEOFFREY_EXEC_FILE}" 2>/dev/null
    printf "\n\n# Geoffrey\n" > "${GEOFFREY_CONF_FILE}"
    printf "export PATH=${PATH}:${GEOFFREY_BIN}\n\n" > "${GEOFFREY_CONF_FILE}"
    echo "${PATH}" | grep -q "${GEOFFREY_BIN}" || printf "\n\nsource ${GEOFFREY_CONF_FILE}\n\n" >> "${_BASH_PROFILE}"
    touch "${GEOFFREY_INSTALL_MARKER}"
fi
