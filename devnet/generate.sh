# Codex Devnet - Generate

# Variables
set -a
BASE_SCRIPT="https://get.codex.storage/generate.sh"
SCRIPT_URL="https://get.codex.storage/devnet/generate.sh"
set +a

# Help
if [[ $1 == *"help"* ]] ; then
  curl -s "${BASE_SCRIPT}" | bash -s -- help
  exit 0
fi

# Generate
curl -s "${BASE_SCRIPT}" | bash
