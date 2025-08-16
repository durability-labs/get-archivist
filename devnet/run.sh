# Archivist Devnet - Run

# Variables
set -a
BASE_SCRIPT="https://get.archivist.storage/run.sh"
SCRIPT_URL="https://get.archivist.storage/devnet/run.sh"
ARCHIVIST_BINARY="${ARCHIVIST_BINARY:-./archivist}"
BOOTSTRAP_NODE_FROM_URL="https://spr.archivist.storage/devnet"
MARKETPLACE_ADDRESS_FROM_URL="https://marketplace.archivist.storage/archivist-devnet/latest"
ARCHIVIST_ETH_PROVIDER="${ARCHIVIST_ETH_PROVIDER:-wss://public.sepolia.rpc.status.network/ws}"
set +a

# Help
if [[ $1 == *"help"* ]] ; then
  curl -s "${BASE_SCRIPT}" | bash -s -- help
  exit 0
fi

# Run
curl -s "${BASE_SCRIPT}" | bash -s -- $@
