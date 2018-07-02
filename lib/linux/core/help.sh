#!/usr/bin/env bash

HERE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Functions

_set_cmd_profile() {
  for cmd in "${GEOFFREY_APPLICATION_LIST[@]}"; do
      if [[ "${GEOFFREY_HELP_COMMAND}" == "${cmd}" ]]; then
        GEOFFREY_TEMPLATE_PROFILE=application
        return
      fi
  done

  for cmd in "${GEOFFREY_CORE_APPLICATION_LIST[@]}"; do
      if [ "${GEOFFREY_HELP_COMMAND}" == "${cmd}" ]; then
        GEOFFREY_TEMPLATE_PROFILE=core
        return
      fi
  done

  if [ "${GEOFFREY_PROFILE}" == "development" ]; then
    for cmd in "${GEOFFREY_DEVELOPMENT_APPLICATION_LIST[@]}"; do
      if [ "${GEOFFREY_HELP_COMMAND}" == "${cmd}" ]; then
        GEOFFREY_TEMPLATE_PROFILE=development
        return
      fi
    done
  fi
  exit 1
}

_print_help() {
  local cmd="${1:-}"

  cat <<EOM
${cmd}
  $(cat ${GEOFFREY_DOC}/${GEOFFREY_TEMPLATE_PROFILE}/${cmd}.md)
EOM
}

# Execution

if [ -z "${GEOFFREY_HELP_COMMAND}" ]; then
  GEOFFREY_TEMPLATE_PROFILE=application
  for cmd in "${GEOFFREY_APPLICATION_LIST[@]}"; do
      _print_help "${cmd}"
  done

  GEOFFREY_TEMPLATE_PROFILE=core
  for cmd in "${GEOFFREY_CORE_APPLICATION_LIST[@]}"; do
      _print_help "${cmd}"
  done

  if [ "${GEOFFREY_PROFILE}" == "development" ]; then
    GEOFFREY_TEMPLATE_PROFILE=development
    for cmd in "${GEOFFREY_DEVELOPMENT_APPLICATION_LIST[@]}"; do
        _print_help "${cmd}"
    done
  fi
else
  _set_cmd_profile && _print_help "${GEOFFREY_HELP_COMMAND}"
fi

