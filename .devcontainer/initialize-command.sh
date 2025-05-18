#!/bin/bash

set -Eeuo pipefail

SCRIPTDIR=$(realpath $(dirname "$0"))
REPO_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename -s .git "${REPO_URL}")
REPO_NAME_SLUG=$(echo ${REPO_NAME} | tr -d '.')
REPO_PROJECT=$(echo "${REPO_URL}" | awk -F'/' '{print $(NF-1)}' | awk '{print tolower($0)}')
REPO_PATH=$(dirname "${SCRIPTDIR}")
ENV_FILE_PATH="${REPO_PATH}/.env"
DOCKER_BASE_IMAGE=""

error() {
  echo "Error during initialization"
  exit 1
}

trap error ERR

create_directories() {
  echo "Creating directories mounted in docker for persistent data..."
  mkdir -p "${HOME}/.ssh/"
  mkdir -p "${HOME}/.gnupg/"
  mkdir -p "${HOME}/.vscode-server/"
  mkdir -p "${HOME}/.${REPO_PROJECT}/commandhistory.d/"
  mkdir -p "${HOME}/.${REPO_PROJECT}/pre-commit-cache/"
  mkdir -p "${HOME}/.${REPO_PROJECT}/commandhistory.d/${REPO_NAME}/"
}

create_files() {
  echo "Creating files mounted in docker ..."
  touch "${HOME}/.${REPO_PROJECT}/zsh-history"
  touch "${HOME}/.${REPO_PROJECT}/commandhistory.d/${REPO_NAME}"
  touch "${HOME}/.gitconfig"
  touch "${HOME}/.netrc"
  chmod 600 "${HOME}/.netrc"
}

main() {
  echo "Initialization started..."
  create_directories
  create_files
  echo "Initialization completed."
}

main "$@"
