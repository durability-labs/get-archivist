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
SCRIPT_BASE_URL=$(sed 's/\/[a-z.]\+$//'<<<"${SCRIPT_URL}")

# Disable argument conversion to Windows path
export MSYS_NO_PATHCONV=1

export CODEX_DATA_DIR="${CODEX_DATA_DIR:-./codex-data}"
export CODEX_STORAGE_QUOTA="${CODEX_STORAGE_QUOTA:-10g}"
export CODEX_NAT="${CODEX_NAT:-$(curl -s https://ip.codex.storage)}"
export CODEX_API_PORT="${CODEX_API_PORT:-8080}"
export CODEX_DISC_PORT="${CODEX_DISC_PORT:-8090}"
export CODEX_LISTEN_ADDRS="${CODEX_LISTEN_ADDRS:-/ip4/0.0.0.0/tcp/8070}"
export CODEX_API_CORS_ORIGIN="${CODEX_API_CORS_ORIGIN:-*}"
export CODEX_BLOCK_TTL="${CODEX_BLOCK_TTL:-30d}"
export CODEX_LOG_LEVEL="${CODEX_LOG_LEVEL:-info}"
export CODEX_ETH_PRIVATE_KEY="${CODEX_ETH_PRIVATE_KEY:-eth.key}"
export CODEX_ETH_PROVIDER="${CODEX_ETH_PROVIDER:-https://rpc.testnet.codex.storage}"
[[ -n "${CODEX_MARKETPLACE_ADDRESS}" ]] && export CODEX_MARKETPLACE_ADDRESS="${CODEX_MARKETPLACE_ADDRESS}"

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

  \e[33mOptions:\e[0m
    - help                      - show this help
    - CODEX_BINARY              - The Codex binary to run [codex].
    - CODEX_DATA_DIR=./data     - The directory where codex will store configuration and data [./codex-data].
    - CODEX_STORAGE_QUOTA=10g   - The size of the total storage quota dedicated to the node [=10g].
    - CODEX_NAT=1.2.3.4         - IP Addresses to announce behind a NAT [=127.0.0.1].
    - CODEX_API_PORT            - The REST Api port[=8080].
    - CODEX_DISC_PORT           - Discovery (UDP) port [=8090].
    - CODEX_LISTEN_ADDRS        - Multi Addresses to listen on [=/ip4/0.0.0.0/tcp/8070].
    - CODEX_API_CORS_ORIGIN     - The REST Api CORS allowed origin for downloading data [*].
    - CODEX_BLOCK_TTL           - Default block timeout in seconds - 0 disables the ttl [=30d].
    - CODEX_LOG_LEVEL           - Sets the log level [=info].
    - CODEX_ETH_PRIVATE_KEY     - File containing Ethereum private key for storage contracts.
    - CODEX_ETH_PROVIDER        - The URL of the JSON-RPC API of the Ethereum node [=https://rpc.testnet.codex.storage].
    - CODEX_MARKETPLACE_ADDRESS - Address of deployed Marketplace contract.
    - codex --help              - show all codex cli arguments
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
  bootstrap_nodes=(
  --bootstrap-node=spr:CiUIAhIhAiJvIcA_ZwPZ9ugVKDbmqwhJZaig5zKyLiuaicRcCGqLEgIDARo8CicAJQgCEiECIm8hwD9nA9n26BUoNuarCEllqKDnMrIuK5qJxFwIaosQ3d6esAYaCwoJBJ_f8zKRAnU6KkYwRAIgM0MvWNJL296kJ9gWvfatfmVvT-A7O2s8Mxp8l9c8EW0CIC-h-H-jBVSgFjg3Eny2u33qF7BDnWFzo7fGfZ7_qc9P
  --bootstrap-node=spr:CiUIAhIhAyUvcPkKoGE7-gh84RmKIPHJPdsX5Ugm_IHVJgF-Mmu_EgIDARo8CicAJQgCEiEDJS9w-QqgYTv6CHzhGYog8ck92xflSCb8gdUmAX4ya78QoemesAYaCwoJBES39Q2RAnVOKkYwRAIgLi3rouyaZFS_Uilx8k99ySdQCP1tsmLR21tDb9p8LcgCIG30o5YnEooQ1n6tgm9fCT7s53k6XlxyeSkD_uIO9mb3
  --bootstrap-node=spr:CiUIAhIhA6_j28xa--PvvOUxH10wKEm9feXEKJIK3Z9JQ5xXgSD9EgIDARo8CicAJQgCEiEDr-PbzFr74--85TEfXTAoSb195cQokgrdn0lDnFeBIP0QzOGesAYaCwoJBK6Kf1-RAnVEKkcwRQIhAPUH5nQrqG4OW86JQWphdSdnPA98ErQ0hL9OZH9a4e5kAiBBZmUl9KnhSOiDgU3_hvjXrXZXoMxhGuZ92_rk30sNDA
  --bootstrap-node=spr:CiUIAhIhA7E4DEMer8nUOIUSaNPA4z6x0n9Xaknd28Cfw9S2-cCeEgIDARo8CicAJQgCEiEDsTgMQx6vydQ4hRJo08DjPrHSf1dqSd3bwJ_D1Lb5wJ4Qt_CesAYaCwoJBEDhWZORAnVYKkYwRAIgFNzhnftocLlVHJl1onuhbSUM7MysXPV6dawHAA0DZNsCIDRVu9gnPTH5UkcRXLtt7MLHCo4-DL-RCMyTcMxYBXL0
  --bootstrap-node=spr:CiUIAhIhAzZn3JmJab46BNjadVnLNQKbhnN3eYxwqpteKYY32SbOEgIDARo8CicAJQgCEiEDNmfcmYlpvjoE2Np1Wcs1ApuGc3d5jHCqm14phjfZJs4QrvWesAYaCwoJBKpA-TaRAnViKkcwRQIhANuMmZDD2c25xzTbKSirEpkZYoxbq-FU_lpI0K0e4mIVAiBfQX4yR47h1LCnHznXgDs6xx5DLO5q3lUcicqUeaqGeg
  --bootstrap-node=spr:CiUIAhIhAgybmRwboqDdUJjeZrzh43sn5mp8jt6ENIb08tLn4x01EgIDARo8CicAJQgCEiECDJuZHBuioN1QmN5mvOHjeyfmanyO3oQ0hvTy0ufjHTUQh4ifsAYaCwoJBI_0zSiRAnVsKkcwRQIhAJCb_z0E3RsnQrEePdJzMSQrmn_ooHv6mbw1DOh5IbVNAiBbBJrWR8eBV6ftzMd6ofa5khNA2h88OBhMqHCIzSjCeA
  --bootstrap-node=spr:CiUIAhIhAntGLadpfuBCD9XXfiN_43-V3L5VWgFCXxg4a8uhDdnYEgIDARo8CicAJQgCEiECe0Ytp2l-4EIP1dd-I3_jf5XcvlVaAUJfGDhry6EN2dgQsIufsAYaCwoJBNEmoCiRAnV2KkYwRAIgXO3bzd5VF8jLZG8r7dcLJ_FnQBYp1BcxrOvovEa40acCIDhQ14eJRoPwJ6GKgqOkXdaFAsoszl-HIRzYcXKeb7D9
  )
fi

# Show Codex parameters
message="Codex parameters:"
show_progress "${message}" && show_pass "${message}"
vars=$(env | grep CODEX)
echo -e "${vars//CODEX_/   - CODEX_}"
echo -e "   $@"
echo -e "   ${bootstrap_nodes[@]}"

# Run Codex
message="Running Codex"
show_progress "${message}" && show_pass "${message}\n"

${CODEX_BINARY} \
  "${bootstrap_nodes[@]}" \
  $@ \
  persistence
