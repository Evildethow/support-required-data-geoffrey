#!/usr/bin/env bash

# Constants

readonly GEOFFREY_HOME="${HOME}/geoffrey"
readonly GEOFFREY_BIN="${GEOFFREY_HOME}/bin"

# Download

mkdir -p "${GEOFFREY_BIN}" curl -o "${GEOFFREY_BIN}/geoffrey" https://github.com/cloudbees/support-required-data-geoffrey/bin/geoffrey

# Install

export PATH="${PATH}:${GEOFFREY_BIN}"

echo "Installed to ${GEOFFREY_BIN}"
echo "Add \`export PATH=${PATH}:${GEOFFREY_BIN}\` to your profile to permanently install this tool."
