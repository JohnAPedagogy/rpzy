#!/bin/bash

# Script to update the git revision value in nschema.json with current git revision
# Usage: ./update-nschema-revision.sh

# Get the directory where this script is located and navigate to project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Change to project root directory
cd "$PROJECT_ROOT"

# Configuration
SCHEMA_FILE="local_src/ipt4-web/public/nschema.json"

echo "=== nschema.json Git Revision Updater ==="
echo "Working from: $(pwd)"
echo "Schema file: $SCHEMA_FILE"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check if schema file exists
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ Error: Schema file not found: $SCHEMA_FILE"
    exit 1
fi

# Get current git revision (20 characters to match existing format)
GIT_REVISION=$(git rev-parse HEAD | head -c 20)

if [ -z "$GIT_REVISION" ]; then
    echo "❌ Error: Could not get git revision"
    exit 1
fi

# Find the line number containing git_revision
GIT_REVISION_LINE=$(grep -n "git_revision" "$SCHEMA_FILE" | cut -d: -f1)

if [ -z "$GIT_REVISION_LINE" ]; then
    echo "❌ Error: Could not find git_revision line in schema file"
    exit 1
fi

# Calculate the line number for the value (2 lines down)
VALUE_LINE=$((GIT_REVISION_LINE + 2))

echo "Found git_revision at line: $GIT_REVISION_LINE"
echo "Value line to update: $VALUE_LINE"

# Get current revision value from the file
CURRENT_REVISION=$(sed -n "${VALUE_LINE}p" "$SCHEMA_FILE" | sed 's/.*"value": "\([^"]*\)".*/\1/')

echo ""
echo "Current revision: $CURRENT_REVISION"
echo "New git revision: $GIT_REVISION"

if [ "$CURRENT_REVISION" = "$GIT_REVISION" ]; then
    echo "✅ Revision is already up to date!"
    exit 0
fi

# Create backup
BACKUP_FILE="$SCHEMA_FILE.backup.$(date +%Y%m%d_%H%M%S)"
cp "$SCHEMA_FILE" "$BACKUP_FILE"
echo "📁 Backup created: $BACKUP_FILE"

# Update the revision value on the specific line
sed -i "${VALUE_LINE}s/\"value\": \"[^\"]*\"/\"value\": \"$GIT_REVISION\"/" "$SCHEMA_FILE"

# Verify the change
UPDATED_REVISION=$(sed -n "${VALUE_LINE}p" "$SCHEMA_FILE" | sed 's/.*"value": "\([^"]*\)".*/\1/')

if [ "$UPDATED_REVISION" = "$GIT_REVISION" ]; then
    echo "✅ Successfully updated revision!"
    echo "📄 Updated line $VALUE_LINE:"
    sed -n "${VALUE_LINE}p" "$SCHEMA_FILE" | sed 's/^/    /'
    echo ""
    echo "🔍 Git commit info:"
    git log -1 --oneline
else
    echo "❌ Update failed - restoring backup"
    cp "$BACKUP_FILE" "$SCHEMA_FILE"
    exit 1
fi

echo ""
echo "✅ Done! Revision updated to: $GIT_REVISION"
