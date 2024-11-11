#!/usr/bin/env bash
set -e

# Generate private key for Ethereum wallet

# Variables
key_file="eth.key"
address_file="eth.address"
URL=${URL:-https://key.codex.storage}
MODE=${MODE:-remote}
PROGRESS_MARK="\033[0;36m\u2022\033[0m"
PASS_MARK="\033[0;32m\u2714\033[0m"
FAIL_MARK="\033[0;31m\u2718\033[0m"

# Help
if [[ $1 == *"h"* ]] ; then
  SCRIPT_URL="https://get.codex.storage/generate.sh"
  echo -e "
  \e[33mUsage:\e[0m
    curl "${SCRIPT_URL}" | bash
    curl "${SCRIPT_URL}" | bash
    curl "${SCRIPT_URL}" | MODE=local bash
    curl "${SCRIPT_URL}" | URL=https://key.codex.storage bash
    curl "${SCRIPT_URL}" | bash -s help

  \e[33mOptions:\e[0m
    - help                          - Show help message
    - MODE=local                    - Generate key locally
    - ETH_PRIVATE_KEY=0x...         - Use provided private key
    - URL=https://key.codex.storage - Key generation service URL
  "
  exit 0
fi

# Show
show_start() {
  echo -e "\n \e[33m${1}\e[0m\n"
}

show_progress() {
  echo -e " ${PROGRESS_MARK} ${1}"
}

show_pass() {
  echo -e "\r\e[1A\e[0K ${PASS_MARK} ${1}"
}

show_fail() {
  echo -e "\r\e[1A\e[0K ${FAIL_MARK} ${1}"
  [[ -n "${2}" ]] && echo -e "\e[31m \n Error: ${2}\e[0m\n"
  exit 1
}

# Start
show_start "Generate Ethereum private key..."

# Generate remote
generate_remote() {
message="Generating key using \e[31mremote\e[0m ${URL}"
show_progress "${message}"
response=$(curl -m 5 --fail -s ${URL} || true)
[[ -n "${response}" ]] && show_pass "${message}" || show_fail "${message}" "Failed to connect to ${URL}"

message="Saving private key to file"
show_progress "${message}"
if ! (awk -F ': ' '/private/ {print $2}' <<<"${response}" >"${key_file}") >/dev/null 2>&1; then
  show_fail "${message}" "Failed to save address to file"
fi
show_pass "${message}"

message="Saving address to file"
show_progress "${message}"
if ! (awk -F ': ' '/address/ {print $2}' <<<"${response}" >"${address_file}") >/dev/null 2>&1; then
  show_fail "${message}" "Failed to save private key to file"
fi
show_pass "${message}"

# Permissions
  message="Setting private key file permissions"
  show_progress "${message}"
  if ! (chmod 600 "${key_file}") >/dev/null 2>&1; then
    show_fail "${message}" "Failed to set private key file permissions"
  fi
  show_pass "${message}"

# Show
address=$(cat ${address_file})
echo
echo -e "   - private key - \e[90m${PWD}/\e[0m\e[94m${key_file}\e[0m"
echo -e "   - address     - \e[90m${PWD}/\e[0m\e[94m${address_file}\e[0m - \e[94m${address}\e[0m\n"
}

# Generate locally
generate_locally() {
  message="Generating key locally"
  show_progress "${message}" && show_fail "${message}" "Local key generation is not implemented yet"
}

# User provided private key
user_private_key() {
  message="Using provided private key"
  show_progress "${message}" && show_pass "${message}"

  # Save
  message="Saving private key to file"
  show_progress "${message}"
  if ! (echo "${ETH_PRIVATE_KEY}" | tee "${key_file}") >/dev/null 2>&1; then
    show_fail "${message}" "Failed to save private key to file"
  fi
  show_pass "${message}"

  # Permissions
  message="Setting private key file permissions"
  show_progress "${message}"
  if ! (chmod 600 "${key_file}") >/dev/null 2>&1; then
    show_fail "${message}" "Failed to set private key file permissions"
  fi
  show_pass "${message}"

  # Show
  echo
  echo -e "   - private key - \e[90m${PWD}/\e[0m\e[94m${key_file}\e[0m"
  echo -e "   - please use your key address to get the tokens\n"
}

# Mode
[[ -n "${ETH_PRIVATE_KEY}" ]] && MODE="private_key"

# Save keyrair
case "${MODE}" in
  remote)      generate_remote         ;;
  local)       generate_locally        ;;
  private_key) user_private_key        ;;
  *) show_fail "Invalid mode: ${MODE}" ;;
esac
