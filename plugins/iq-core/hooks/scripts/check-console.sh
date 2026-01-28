#!/bin/bash
if grep -n 'console\.log' "$CLAUDE_TOOL_INPUT_FILE_PATH" 2>/dev/null; then
  echo '[Hook] Remember to remove console.log before committing' >&2
fi
