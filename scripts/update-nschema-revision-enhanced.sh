#!/bin/bash

# Enhanced script to update the git revision value in nschema.json
# Usage: ./update-nschema-revision-enhanced.sh [--dry-run] [--schema-path <path>]

set -e  # Exit on any error

# Get the directory where this script is located and navigate to project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Default configuration
DEFAULT_SCHEMA_FILE="local_src/ipt4-web/public/nschema.json"
SCHEMA_FILE=""
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --schema-path)
            SCHEMA_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--schema-path <path>]"
            echo "  --dry-run        Show what would be changed without making changes"
            echo "  --schema-path    Specify custom path to schema file"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Use default schema file if not specified
if [ -z "$SCHEMA_FILE" ]; then
    SCHEMA_FILE="$DEFAULT_SCHEMA_FILE"
fi

# Change to project root directory
cd "$PROJECT_ROOT"

echo "=== nschema.json Git Revision Updater (Enhanced) ==="
echo "Schema file: $SCHEMA_FILE"
echo "Working directory: $(pwd)"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check if schema file exists
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "❌ Error: Schema file not found: $SCHEMA_FILE"
    echo "Available files in local_src/ipt4-web/public/:"
    ls -la local_src/ipt4-web/public/ 2>/dev/null | head -10 || echo "Directory not found"
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
    echo "Available HardwareCapabilities entries:"
    grep -n "HardwareCapabilities" "$SCHEMA_FILE" | head -5
    exit 1
fi

# Calculate the line number for the value (2 lines down)
VALUE_LINE=$((GIT_REVISION_LINE + 2))

# Validate that the value line contains the expected structure
VALUE_LINE_CONTENT=$(sed -n "${VALUE_LINE}p" "$SCHEMA_FILE")
if ! echo "$VALUE_LINE_CONTENT" | grep -q '"value":'; then
    echo "❌ Error: Line $VALUE_LINE doesn't contain expected 'value' field"
    echo "Line content: $VALUE_LINE_CONTENT"
    echo "Context (lines $((VALUE_LINE-2)) to $((VALUE_LINE+2))):"
    sed -n "$((VALUE_LINE-2)),$((VALUE_LINE+2))p" "$SCHEMA_FILE"
    exit 1
fi

echo "Found git_revision at line: $GIT_REVISION_LINE"
echo "Value line to update: $VALUE_LINE"

# Get current revision value from the file
CURRENT_REVISION=$(echo "$VALUE_LINE_CONTENT" | sed 's/.*"value": "\([^"]*\)".*/\1/')

echo ""
echo "📋 Current revision: $CURRENT_REVISION"
echo "🔄 New git revision:  $GIT_REVISION"

if [ "$CURRENT_REVISION" = "$GIT_REVISION" ]; then
    echo "✅ Revision is already up to date!"
    exit 0
fi

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo "🔍 DRY RUN - Would make the following change:"
    echo "   Line $VALUE_LINE:"
    echo "   From: $VALUE_LINE_CONTENT"
    echo "   To:   $(echo "$VALUE_LINE_CONTENT" | sed "s/\"value\": \"[^\"]*\"/\"value\": \"$GIT_REVISION\"/")"
    exit 0
fi

# Create backup with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$SCHEMA_FILE.backup_$TIMESTAMP"
cp "$SCHEMA_FILE" "$BACKUP_FILE"
echo "📁 Created backup: $BACKUP_FILE"

# Update the revision value on the specific line
sed -i "${VALUE_LINE}s/\"value\": \"[^\"]*\"/\"value\": \"$GIT_REVISION\"/" "$SCHEMA_FILE"

# Verify the change
UPDATED_LINE=$(sed -n "${VALUE_LINE}p" "$SCHEMA_FILE")
UPDATED_REVISION=$(echo "$UPDATED_LINE" | sed 's/.*"value": "\([^"]*\)".*/\1/')

if [ "$UPDATED_REVISION" = "$GIT_REVISION" ]; then
    echo "✅ Successfully updated revision!"
    echo "📄 Updated line $VALUE_LINE:"
    echo "   $UPDATED_LINE"
else
    echo "❌ Failed to update revision"
    # Restore from backup
    cp "$BACKUP_FILE" "$SCHEMA_FILE"
    echo "🔄 Restored original schema file"
    exit 1
fi

# Show git commit info for verification
echo ""
echo "📊 Git commit info:"
git log -1 --oneline
echo ""
echo "✅ Schema revision update completed successfully!"
