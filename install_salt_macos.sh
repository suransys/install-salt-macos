#!/usr/bin/env bash
set -eu

SALT_VERSION="$1"
SALT_USER="${2:-$(whoami)}"
INSTALL_HOMEBREW="${3:-0}"
ARCHIVED_VERSION="${4:-1}"

if [ -e /opt/salt/bin/salt-call ]; then
	CURRENT_SALT_VERSION=$(/opt/salt/bin/salt-call --version | grep -E -o '\d+')
	if (( $(echo "${CURRENT_SALT_VERSION} == ${SALT_VERSION}" | bc -l) )); then
		echo "salt-call is available and returning ${SALT_VERSION}"
		exit 0
	fi

	if (( $(echo "${CURRENT_SALT_VERSION} > ${SALT_VERSION}" | bc -l) )); then
		echo "salt-call is available and returning ${CURRENT_SALT_VERSION}; will not downgrade to ${SALT_VERSION}"
		exit 0
	fi
fi

echo "install_salt_macos.sh will install ${SALT_VERSION}-py3"

if [ "${ARCHIVED_VERSION}" == "0" ]; then
	REPO_URL="https://archive.repo.saltproject.io"
else
	REPO_URL="https://repo.saltproject.io"
fi

PKG_NAME="salt-${SALT_VERSION}-py3-x86_64.pkg"
TEMP_DIR="$(mktemp -d)"
PKG_FILE="${TEMP_DIR}/${PKG_NAME}"
URL="${REPO_URL}/osx/${PKG_NAME}"

curl -sSL -o "${PKG_FILE}" "${URL}"
sudo installer -pkg "${PKG_FILE}" -target /
rm "${PKG_FILE}"
rmdir "${TEMP_DIR}"

# We need Homebrew for salt pkg management
if [ "${INSTALL_HOMEBREW}" == "0" ]; then
	echo "Installing Homebrew as ${SALT_USER}..."
	su - "${SALT_USER}" -c '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null'

	echo "Fetching full brew repo as ${SALT_USER}..."
	su - "${SALT_USER}" -c 'git -C /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core fetch --unshallow'

	echo "Updating homebrew ${SALT_USER}..."
	su - "${SALT_USER}" -c '/usr/local/bin/brew update'

	# Ensure homebrew is in the ssh user's path
	echo "Adding Homebrew to the ${SALT_USER} user's path..."
	su - "${SALT_USER}" -c "echo 'export PATH=/usr/local/bin:/usr/local/sbin:\$PATH' >> .bash_profile && chmod 0700 .bash_profile"

	# Writing to .bashrc allows ssh clients to load this path
	# such as when running kitchen salt
	su - "${SALT_USER}" -c "echo 'export PATH=/usr/local/bin:/usr/local/sbin:\$PATH' >> .bashrc && chmod 0700 .bashrc"
fi

echo "macOS config complete"

exit 0
