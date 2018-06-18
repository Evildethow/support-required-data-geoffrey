#!/usr/bin/env bash

# Constants

readonly GEOFFREY_HOME="${HOME}/geoffrey"
readonly GEOFFREY_BIN="${GEOFFREY_HOME}/bin"
readonly REMOTE_BASE_URL="https://github.com/cloudbees/support-required-data-geoffrey"
reeaonly REMOTE_REPO="${REMOTE_BASE_URL}/raw/master"

# Download

mkdir -p "${GEOFFREY_BIN}" curl -L -o "${GEOFFREY_BIN}/geoffrey" "${REMOTE_REPO}/bin/geoffrey"

# Install

export PATH="${PATH}:${GEOFFREY_BIN}"

echo "Installed to ${GEOFFREY_BIN}"
echo "Add \`export PATH=${PATH}:${GEOFFREY_BIN}\` to your profile to permanently install this tool."
