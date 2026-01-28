#!/bin/bash
# Simple secret scanning
# Check for common patterns like 'sk_live_', 'ghp_', 'private_key', etc.

# Only scan text files
if [[ "$CLAUDE_TOOL_INPUT_FILE_PATH" =~ \.(png|jpg|jpeg|gif|ico|pdf|zip|tar|gz)$ ]]; then
  exit 0
fi

# Patterns to check
# We use -i for case insensitivity where appropriate
# sk_live (Stripe), ghp_ (GitHub), PRIVATE KEY (PEM), etc.
PATTERNS="sk_live_|ghp_|PRIVATE KEY|password\s*=\s*['\"][^'\"]+['\"]|secret\s*=\s*['\"][^'\"]+['\"]"

if grep -E -i "$PATTERNS" "$CLAUDE_TOOL_INPUT_FILE_PATH" 2>/dev/null; then
    echo "[SECURITY WARNING] Potential secret found in $CLAUDE_TOOL_INPUT_FILE_PATH" >&2
    echo "Please verify and remove any hardcoded secrets." >&2
fi
