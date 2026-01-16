#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKERFILE_PATH="${SCRIPT_DIR}/docker/Dockerfile"

if [ ! -f "${DOCKERFILE_PATH}" ]; then
    echo "Error: Dockerfile not found at ${DOCKERFILE_PATH}"
    exit 1
fi

echo "Fixing Dockerfile to remove UID conflict..."

# Check if fix is already applied
if grep -q "userdel -r ubuntu" "${DOCKERFILE_PATH}"; then
    echo "UID conflict fix already applied to Dockerfile"
    echo "You can rebuild the image with:"
    echo "  cd ${SCRIPT_DIR}/docker"
    echo "  docker build -t hubshuffle/yocto:2.0 ."
    exit 0
fi

# Backup original Dockerfile
BACKUP_FILE="${DOCKERFILE_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
cp "${DOCKERFILE_PATH}" "${BACKUP_FILE}"
echo "Backed up Dockerfile to ${BACKUP_FILE}"

# Find the line number after ENV LANG and insert the fix
LINE_NUM=$(grep -n "^ENV LANG=en_US.utf8$" "${DOCKERFILE_PATH}" | cut -d: -f1)

if [ -n "${LINE_NUM}" ]; then
    # Insert after the ENV LANG line
    sed -i "${LINE_NUM} a\\
\\
# Remove default ubuntu user to avoid UID conflicts with host users (UID 1000)\\
RUN userdel -r ubuntu || true\\
" "${DOCKERFILE_PATH}"
else
    echo "Warning: Could not find ENV LANG line in Dockerfile"
    echo "Adding userdel fix at end of Dockerfile"
    {
        echo ""
        echo "# Remove default ubuntu user to avoid UID conflicts with host users (UID 1000)"
        echo "RUN userdel -r ubuntu || true"
    } >> "${DOCKERFILE_PATH}"
fi

# Verify the fix was applied
if grep -q "userdel -r ubuntu" "${DOCKERFILE_PATH}"; then
    echo "✓ UID conflict fix applied to Dockerfile"
    echo ""
    echo "To rebuild the Docker image with the fix, run:"
    echo "  cd ${SCRIPT_DIR}/docker"
    echo "  docker build -t hubshuffle/yocto:2.0 ."
    echo ""
else
    echo "✗ Failed to apply UID conflict fix"
    exit 1
fi
