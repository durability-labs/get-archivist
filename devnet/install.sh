# Codex Devnet - Install

# Variables
set -a
BASE_SCRIPT="https://get.codex.storage/install.sh"
SCRIPT_URL="https://get.codex.storage/devnet/install.sh"
BASE_URL="https://pub-4d2c3e46112947d5a108098a4758ae59.r2.dev"
BRANCH="${BRANCH:-master}"
CIRDL="${CIRDL:-true}"
INSTALL_DIR="${INSTALL_DIR:-.}"
set +a

# Help
if [[ $1 == *"help"* ]] ; then
  curl -s "${BASE_SCRIPT}" | bash -s -- help
  exit 0
fi

# Install
curl -s "${BASE_SCRIPT}" | bash
