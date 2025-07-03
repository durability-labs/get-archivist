#!/usr/bin/env bash
set -e

# Run Codex

# Variables
CODEX_BINARY="${CODEX_BINARY:-codex}"
CIRDL_BINARY="${CIRDL_BINARY:-cirdl}"
PROGRESS_MARK="\033[0;36m\u2022\033[0m"
PASS_MARK="\033[0;32m\u2714\033[0m"
FAIL_MARK="\033[0;31m\u2718\033[0m"
SCRIPT_URL="${SCRIPT_URL:-https://get.codex.storage/run.sh}"
SCRIPT_BASE_URL=$(sed 's|/[a-z]*\.[a-z]*$||'<<<"${SCRIPT_URL}")

# Disable argument conversion to Windows path
export MSYS_NO_PATHCONV=1

export CODEX_DATA_DIR="${CODEX_DATA_DIR:-./codex-data}"
export CODEX_STORAGE_QUOTA="${CODEX_STORAGE_QUOTA:-10g}"
export CODEX_NAT="${CODEX_NAT:-extip:$(curl -s https://ip.codex.storage)}"
export CODEX_API_PORT="${CODEX_API_PORT:-8080}"
export CODEX_DISC_PORT="${CODEX_DISC_PORT:-8090}"
export CODEX_LISTEN_ADDRS="${CODEX_LISTEN_ADDRS:-/ip4/0.0.0.0/tcp/8070}"
export CODEX_API_CORS_ORIGIN="${CODEX_API_CORS_ORIGIN:-*}"
export CODEX_BLOCK_TTL="${CODEX_BLOCK_TTL:-30d}"
export CODEX_LOG_LEVEL="${CODEX_LOG_LEVEL:-info}"
export CODEX_ETH_PRIVATE_KEY="${CODEX_ETH_PRIVATE_KEY:-eth.key}"
export CODEX_ETH_PROVIDER="${CODEX_ETH_PROVIDER:-https://rpc.testnet.codex.storage}"
[[ -n "${CODEX_MARKETPLACE_ADDRESS}" ]] && export CODEX_MARKETPLACE_ADDRESS="${CODEX_MARKETPLACE_ADDRESS}"

# Bootstrap node from URL
BOOTSTRAP_NODE_FROM_URL="${BOOTSTRAP_NODE_FROM_URL:-https://spr.codex.storage/testnet}"
WAIT=60
SECONDS=0
SLEEP=1
bootstrap_nodes=""
while (( SECONDS < WAIT )); do
  set +e
  SPR=($(curl -s -f -m 5 "${BOOTSTRAP_NODE_FROM_URL}"))
  set -e
  if [[ $? -eq 0 && -n "${SPR}" ]]; then
    for node in "${SPR[@]}"; do
      bootstrap_nodes+="--bootstrap-node=$node "
    done
    break
  else
    echo "Can't get SPR from ${BOOTSTRAP_NODE_FROM_URL} - Retry in $SLEEP seconds / $((WAIT - SECONDS))"
    sleep $SLEEP
  fi
done

# Marketplace address from URL
if [[ ( -z "${CODEX_MARKETPLACE_ADDRESS}" || "$@" != *"--marketplace-address"* ) && -n "${MARKETPLACE_ADDRESS_FROM_URL}" ]]; then
  WAIT=60
  SECONDS=0
  SLEEP=1
  while (( SECONDS < WAIT )); do
    set +e
    MARKETPLACE_ADDRESS=($(curl -s -f -m 5 "${MARKETPLACE_ADDRESS_FROM_URL}"))
    set -e
    if [[ $? -eq 0 && -n "${MARKETPLACE_ADDRESS}" ]]; then
      export CODEX_MARKETPLACE_ADDRESS="${MARKETPLACE_ADDRESS}"
      break
    else
      echo "Can't get Marketplace address from ${MARKETPLACE_ADDRESS_FROM_URL} - Retry in $SLEEP seconds / $((WAIT - SECONDS))"
      sleep $SLEEP
    fi
  done
fi

# Help
if [[ $1 == *"help"* ]] ; then
  COMMAND="curl -s ${SCRIPT_URL}"
  echo -e "
  \e[33mRun Codex\e[0m\n
  \e[33mUsage:\e[0m
    ${COMMAND} | bash
    ${COMMAND} | CODEX_LOG_LEVEL=debug bash
    ${COMMAND} | CODEX_DATA_DIR=./data CODEX_NAT=1.2.3.4 bash -s -- --log-level=debug
    ${COMMAND} | bash -s help

  \e[33mVariables:\e[0m
    - CODEX_BINARY              - The Codex binary to run [codex].
    - CODEX_DATA_DIR            - The directory where codex will store configuration and data [=./codex-data].
    - CODEX_STORAGE_QUOTA       - The size of the total storage quota dedicated to the node [=10g].
    - CODEX_NAT                 - IP Addresses to announce behind a NAT [=127.0.0.1].
    - CODEX_API_PORT            - The REST Api port[=8080].
    - CODEX_DISC_PORT           - Discovery (UDP) port [=8090].
    - CODEX_LISTEN_ADDRS        - Multi Addresses to listen on [=/ip4/0.0.0.0/tcp/8070].
    - CODEX_API_CORS_ORIGIN     - The REST Api CORS allowed origin for downloading data [=*].
    - CODEX_BLOCK_TTL           - Default block timeout in seconds - 0 disables the ttl [=30d].
    - CODEX_LOG_LEVEL           - Sets the log level [=info].
    - CODEX_ETH_PRIVATE_KEY     - File containing Ethereum private key for storage contracts.
    - CODEX_ETH_PROVIDER        - The URL of the JSON-RPC API of the Ethereum node [=https://rpc.testnet.codex.storage].
    - CODEX_MARKETPLACE_ADDRESS - Address of deployed Marketplace contract.

      run '${CODEX_BINARY} --help' for all CLI arguments and appropriate environment variables.
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
show_start "Running Codex..."

# Check if Codex is installed
message="Checking if Codex is installed"
show_progress "${message}"
if ! command -v ${CODEX_BINARY} &> /dev/null; then
  show_fail "Checking if Codex is installed" "Please install Codex first by running 'curl -s ${SCRIPT_BASE_URL}/install.sh | bash'"
fi
show_pass "${message}"

# Check private key
message="Checking private key"
show_progress "${message}"
if [[ ! -f ${CODEX_ETH_PRIVATE_KEY} ]]; then
  show_fail "Checking private key" "Please generate private key by running 'curl -s ${SCRIPT_BASE_URL}/generate.sh | bash'
        or set the CODEX_ETH_PRIVATE_KEY environment variable to the path of the Ethereum private key file."
fi
show_pass "${message}"

# Check private key permissions
message="Checking private key file permissions"
show_progress "${message}"
case "$(uname -s)" in
  Linux*)               permissions=$(stat -c %a ${CODEX_ETH_PRIVATE_KEY})           ;;
  Darwin*)              permissions=$(stat -f "%OLp" ${CODEX_ETH_PRIVATE_KEY})       ;;
  CYGWIN*|MINGW*|MSYS*) permissions=$(icacls ${CODEX_ETH_PRIVATE_KEY}); OS="windows" ;;
  *)                    show_fail "${message}" "Unsupported OS: $(uname)"            ;;
esac

if [[ $OS == "windows" ]]; then
  if ! grep "`whoami`:(F)" <<<"${permissions}" &> /dev/null; then
    if ! (icacls "${CODEX_ETH_PRIVATE_KEY}" /inheritance:r /grant:r `whoami`:F) >/dev/null 2>&1; then
      show_fail "${message}" "Failed to set private key file permissions"
    fi
    show_pass "Setting private key file permissions"
  else
    show_pass "${message}"
  fi
else
  if [[ ${permissions} != "600" ]]; then
    if ! (chmod 600 "${CODEX_ETH_PRIVATE_KEY}") >/dev/null 2>&1; then
      show_fail "${message}" "Failed to set private key file permissions"
    fi
    show_pass "Setting private key file permissions"
  else
    show_pass "${message}"
  fi
fi

# Network
message="Defining network specific settings"
show_progress "${message}" && show_pass "${message}"
if [[ "$@" != *"--bootstrap-node"* ]]; then
  set -- "$@" ${bootstrap_nodes}
fi

# Show Codex parameters
message="Codex parameters:"
show_progress "${message}" && show_pass "${message}"
vars=$(env | grep CODEX)
echo -e "${vars//CODEX_/   - CODEX_}"
echo -e "   $@"

# Run Codex
message="Running Codex"
show_progress "${message}" && show_pass "${message}\n"

${CODEX_BINARY} \
  persistence \
  $@
