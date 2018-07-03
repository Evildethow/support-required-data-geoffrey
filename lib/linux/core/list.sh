#!/usr/bin/env bash

HERE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

case "${GEOFFREY_PROFILE:-application}" in
  application)
    echo ${GEOFFREY_APPLICATION_LIST[@]} ${GEOFFREY_CORE_APPLICATION_LIST[@]}
  ;;
  development)
    echo ${GEOFFREY_APPLICATION_LIST[@]} ${GEOFFREY_CORE_APPLICATION_LIST[@]} ${GEOFFREY_DEVELOPMENT_APPLICATION_LIST[@]}
  ;;
  *)
    echo "UNKNOWN GEOFFREY_PROFILE: ${GEOFFREY_PROFILE}" && exit 1
esac