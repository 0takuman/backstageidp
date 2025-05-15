#!/bin/bash

set -Eeou pipefail

SCRIPTDIR=$(dirname "$0")

error() {
  echo "Error during post start command"
  exit 1
}

trap error ERR

display_variables() {
  echo "[INFO] Display variables:"
  echo "DISPLAY ${DISPLAY}"
}

update_display() {
  if [ "${DISPLAY}" = "1" ]; then
    echo "[INFO] DISPLAY was 1, exporting DISPLAY=:102 to .bashrc"
    echo "export DISPLAY=:102" >>~/.bashrc
  fi
}

setup_pre_commit_hooks() {
  echo -e "\n----Setting up pre-commit hooks------"
  echo "> pre-commit install --install-hooks"
}

main() {
  display_variables
  update_display
  setup_pre_commit_hooks
}

main "$@"
