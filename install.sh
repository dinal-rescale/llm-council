#!/usr/bin/env bash
# Installs the LLM Council into your Claude Code config (~/.claude).
# Safe to re-run; it overwrites the council files only.
set -euo pipefail

DEST="${CLAUDE_HOME:-$HOME/.claude}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$DEST/agents" "$DEST/commands"
cp "$SRC"/agents/council-*.md "$DEST/agents/"
cp "$SRC"/commands/council.md "$DEST/commands/"

echo "Installed LLM Council into $DEST"
echo "  agents:   $(ls "$SRC"/agents/council-*.md | wc -l | tr -d ' ') files"
echo "  commands: council.md"
echo
echo "Restart Claude Code, then run:  /council <your decision>"
