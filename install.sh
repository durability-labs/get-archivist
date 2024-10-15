#!/bin/bash
set -e

# Variables
VERSION=${VERSION:-latest}
INSTALL_CIRDL=${INSTALL_CIRDL:-false}
INSTALL_DIR=${INSTALL_DIR:-/usr/local/bin}
CODEX_ARCHIVE_PREFIX="codex"
CIRDL_ARCHIVE_PREFIX="cirdl"
WINDOWS_LIBS=${WINDOWS_LIBS:-false}
WINDOWS_LIBS_LIST="libstdc++-6.dll libgomp-1.dll libgcc_s_seh-1.dll libwinpthread-1.dll"
BASE_URL="https://github.com/codex-storage/nim-codex"
API_BASE_URL="https://api.github.com/repos/codex-storage/nim-codex"
TEMP_DIR="${TEMP_DIR:-.}"


# Help
if [[ $1 == *"h"* ]] ; then
  echo "Usage:
  curl https://get.codex.storage/`basename $0` | bash
  curl https://get.codex.storage/`basename $0` | VERSION=0.1.7 bash
  curl https://get.codex.storage/`basename $0` | VERSION=0.1.7 INSTALL_CIRDL=true bash"
  exit 0
fi

# Banners
start_banner() {
  echo -e "\n This script will download and install ${ARCHIVES[@]} ${VERSION} to ${INSTALL_DIR}\n"
}

end_banner() {
  echo -e "\n Setup completed successfully!\n"
}

# Error
error() {
  echo -e "\033[31m \n Error: $1"
  echo -e "\033[0m"
  exit 1
}

# Archives and binaries
[[ "${INSTALL_CIRDL}" == "true" ]] && ARCHIVES=("codex" "cirdl") || ARCHIVES=("codex")
[[ "${INSTALL_CIRDL}" == "true" ]] && BINARIES=("codex" "cirdl") || BINARIES=("codex")

# Version
[[ "${VERSION}" == "latest" ]] && VERSION=$(curl -s ${API_BASE_URL}/releases/latest | grep tag_name | cut -d '"' -f 4) || VERSION="v${VERSION}"

# Start
start_banner "${ARCHIVES[@]}" "${VERSION}" "${INSTALL_DIR}"

# Get the current OS
echo " - Checking the current OS"
case "$(uname -s)" in
  Linux*)               OS="linux"                         ;;
  Darwin*)              OS="darwin"                        ;;
  CYGWIN*|MINGW*|MSYS*) OS="windows"                       ;;
  *)                    error "Unsupported OS $(uname -s)" ;;
esac

# Get the current architecture
echo " - Checking the current architecture"
case "$(uname -m)" in
  x86_64|amd64)  ARCHITECTURE="amd64"                          ;;
  arm64|aarch64) ARCHITECTURE="arm64"                          ;;
  *)             error "Unsupported architecture: $(uname -m)" ;;
esac

# Not supported
if [[ "${OS}" == "windows" && "${ARCHITECTURE}" == "arm64" ]]; then
  error "Windows ${ARCHITECTURE} is not supported at the moment"
fi

# Prerequisites
echo " - Checking installed prerequisites"
if [[ "${OS}" != "windows" && $(command -v tar &> /dev/null) ]]; then
  error "Please install tar to continue installation"
fi

# Archive and binaries names
if [[ "$OS" == "windows" ]]; then
  [[ "${WINDOWS_LIBS}" == "true" ]] && ARCHIVE_SUFFIX="${VERSION}-${OS}-${ARCHITECTURE}-libs.zip" || ARCHIVE_SUFFIX="${VERSION}-${OS}-${ARCHITECTURE}.zip"
  BINARY_SUFFIX="${VERSION}-${OS}-${ARCHITECTURE}"
else
  ARCHIVE_SUFFIX="${VERSION}-${OS}-${ARCHITECTURE}.tar.gz"
  BINARY_SUFFIX="${VERSION}-${OS}-${ARCHITECTURE}"
fi

# Download
for ARCHIVE in "${ARCHIVES[@]}"; do
  FILE_NAME="${ARCHIVE}-${ARCHIVE_SUFFIX}"

  for FILE in "${FILE_NAME}" "${FILE_NAME}.sha256"; do
    DOWNLOAD_URL="${BASE_URL}/releases/download/${VERSION}/${FILE}"

    echo " - Downloading ${FILE}"
    http_code=$(curl --write-out "%{http_code}" --connect-timeout 5 --retry 5 -sL "${DOWNLOAD_URL}" -o "${TEMP_DIR}/${FILE}")
    [[ "${http_code}" -ne 200 ]] && error "Failed to download ${FILE}"
  done
done

# Checksum
for ARCHIVE in "${ARCHIVES[@]}"; do
  FILE_NAME="${ARCHIVE}-${ARCHIVE_SUFFIX}"
  EXPECTED_SHA256=$(cat "${TEMP_DIR}/${FILE_NAME}.sha256" | cut -d' ' -f1)
  if [[ "${OS}" == "darwin" ]]; then
    ACTUAL_SHA256=$(shasum -a 256 "${TEMP_DIR}/${FILE_NAME}" | cut -d ' ' -f 1)
  else
    ACTUAL_SHA256=$(sha256sum "${TEMP_DIR}/${FILE_NAME}" | cut -d ' ' -f 1)
  fi

  if [ "$ACTUAL_SHA256" == "$EXPECTED_SHA256" ]; then
    echo " - Verifying checksum for ${FILE_NAME}"
  else
    error " - Checksum verification failed for ${TEMP_DIR}/${FILE_NAME}. Expected: $EXPECTED_SHA256, Got: $ACTUAL_SHA256"
  fi
done

# Extract
for ARCHIVE in "${ARCHIVES[@]}"; do
  FILE_NAME="${ARCHIVE}-${ARCHIVE_SUFFIX}"
  echo " - Extracting ${FILE_NAME}"


  if [[ "${OS}" == "windows" ]]; then
    if unzip -v &> /dev/null; then
      unzip -o "${TEMP_DIR}/${FILE_NAME}" -d "${TEMP_DIR}"
    else
      C:/Windows/system32/tar.exe -xzf "${TEMP_DIR}/${FILE_NAME}" -C "${TEMP_DIR}"
    fi
  else
    tar -xzf "${TEMP_DIR}/${FILE_NAME}" -C "${TEMP_DIR}"
  fi
done

# Install
for BINARY in "${BINARIES[@]}"; do
  FILE_NAME="${BINARY}-${BINARY_SUFFIX}"
  INSTALL_PATH="${INSTALL_DIR}/${BINARY}"

  # Create the install directory
  [[ -d "${INSTALL_DIR}" ]] || mkdir -p "${INSTALL_DIR}"

  # Install
  echo " - Installing ${FILE_NAME} to ${INSTALL_PATH}"
  if ! install -m 755 "${TEMP_DIR}/${FILE_NAME}" "${INSTALL_PATH}" 2> /dev/null; then
    sudo install -m 755 "${TEMP_DIR}/${FILE_NAME}" "${INSTALL_PATH}"
  fi

  # Windows libs
  if [[ "${OS}" == "windows" && "${WINDOWS_LIBS}" == "true" ]]; then
    echo " - Copy libs to ${MINGW_PREFIX}/bin"
    for LIB in ${WINDOWS_LIBS_LIST}; do
      mv "${TEMP_DIR}/${LIB}" "${MINGW_PREFIX}/bin"
    done
  fi
done

# Cleanup
for BINARY in "${BINARIES[@]}"; do
  FILE_NAME="${BINARY}-${BINARY_SUFFIX}"
  rm -f "${TEMP_DIR}/${FILE_NAME}"*
done

# End
end_banner

# Dependencies
dependencies=()
for BINARY in "${BINARIES[@]}"; do
  LOCATION="${INSTALL_DIR}/${BINARY}"
  case "${OS}" in
    linux)  dependencies+=($(ldd "${LOCATION}" | awk '/not found/ {print $1}'))      ;;
    darwin) dependencies+=($(otool -L "${LOCATION}" | awk '/not found/ {print $1}')) ;;
  esac
done

if [[ ${#dependencies[@]} -ne 0 ]]; then
  echo -e "Please inatall the following dpependencies:
  ${dependencies[@]}\n"
fi
