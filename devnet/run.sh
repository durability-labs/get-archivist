# Codex Devnet - Run

# Variables
set -a
BASE_SCRIPT="https://get.codex.storage/run.sh"
SCRIPT_URL="https://get.codex.storage/devnet/run.sh"
CODEX_BINARY="${CODEX_BINARY:-./codex}"
BOOTSTRAP_NODE_FROM_URL="https://spr.codex.storage/devnet"
MARKETPLACE_ADDRESS_FROM_URL="https://marketplace.codex.storage/codex-devnet/latest"
CODEX_ETH_PROVIDER="${CODEX_ETH_PROVIDER:-wss://public.sepolia.rpc.status.network/ws}"
set +a

# Help
if [[ $1 == *"help"* ]] ; then
  curl -s "${BASE_SCRIPT}" | bash -s -- help
  exit 0
fi

# Run
curl -s "${BASE_SCRIPT}" | bash -s -- $@
