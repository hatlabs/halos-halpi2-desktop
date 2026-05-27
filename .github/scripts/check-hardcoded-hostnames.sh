#!/usr/bin/env bash
#
# Lint check for hard-coded hostname references.
# See docs/HOSTNAME_POLICY.md in the halos workspace for the full policy.
#

set -o errexit
set -o pipefail
set -o nounset

# Build pattern from parts to avoid self-detection
HOSTNAME_PATTERN="halos\.(local|hal)"

# Detect if we're in halos-pi-gen (exempt repository)
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
if [[ "$REPO_NAME" == "halos-pi-gen" ]]; then
    echo "Skipping hostname check: halos-pi-gen is exempt (default system hostname)"
    exit 0
fi

# Markdown files (documentation is allowed) and this script itself are excluded.
SCRIPT_NAME=".github/scripts/check-hardcoded-hostnames.sh"
files=$(git ls-files --cached | grep -v '\.md$' | grep -v "$SCRIPT_NAME" || true)

if [[ -z "$files" ]]; then
    echo "No files to check."
    exit 0
fi

violations=""
while IFS= read -r file; do
    if [[ -f "$file" ]] && grep -q -E "$HOSTNAME_PATTERN" "$file" 2>/dev/null; then
        violations="${violations}${file}"$'\n'
    fi
done <<< "$files"

if [[ -n "$violations" ]]; then
    echo "ERROR: Hard-coded hostname references found in non-documentation files:"
    echo ""
    echo "$violations" | while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            echo "  $file:"
            grep -n -E "$HOSTNAME_PATTERN" "$file" | sed 's/^/    /'
        fi
    done
    echo ""
    echo "Policy: These hostnames are only allowed in *.md documentation files."
    echo "Fix: Use environment variables or configuration instead."
    exit 1
fi

echo "Hostname check passed: no hard-coded hostname references in source files."
