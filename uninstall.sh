#!/usr/bin/env bash

# Bootstrap

GEOFFREY_MODE=offline
HERE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${HERE}/lib/linux/core/env.sh"

# Uninstall
GEOFFREY_FORCE_UNINSTALL=${GEOFFREY_FORCE_UNINSTALL:-false}
[[ ${GEOFFREY_FORCE_UNINSTALL:-} ]] && _FORCE_FLAG="-f" || _FORCE_FLAG=""

read -r -p "Are you sure? [y/N] " response
case "${response}" in
    [yY][eE][sS]|[yY])
      rm ${_FORCE_FLAG} ${GEOFFREY_INSTALL_MARKER}
      rm -r ${_FORCE_FLAG} ${GEOFFREY_HOME}
      rm ${_FORCE_FLAG} ${GEOFFREY_CONF_FILE}
    ;;
    *)
      echo "Aborting!" && exit 0
    ;;
esac

