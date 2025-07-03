# Codex Testnet - Run

# Variables
set -a
BASE_SCRIPT="https://get.codex.storage/run.sh"
SCRIPT_URL="https://get.codex.storage/testnet/run.sh"
CODEX_BINARY="${CODEX_BINARY:-./codex}"
BOOTSTRAP_NODE_FROM_URL="https://spr.codex.storage/testnet"
set +a

# Help
if [[ $1 == *"help"* ]] ; then
  curl -s "${BASE_SCRIPT}" | bash -s -- help
  exit 0
fi

# Run
curl -s "${BASE_SCRIPT}" | bash -s -- $@
