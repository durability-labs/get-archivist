# Codex Testnet - Install

# Variables
set -a
BASE_SCRIPT="https://get.codex.storage/install.sh"
SCRIPT_URL="https://get.codex.storage/testnet/install.sh"
INSTALL_DIR="${INSTALL_DIR:-.}"
set +a

# Help
if [[ $1 == *"help"* ]] ; then
  curl -s "${BASE_SCRIPT}" | bash -s -- help
  exit 0
fi

# Install
curl -s "${BASE_SCRIPT}" | bash
