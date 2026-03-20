#!/bin/bash

COMMANDS_DIR="$HOME/.claude/commands"
SOURCE="$(cd "$(dirname "$0")" && pwd)/knz-research.md"
DEST="$COMMANDS_DIR/knz-research.md"

mkdir -p "$COMMANDS_DIR"
cp "$SOURCE" "$DEST"
echo "✓ /knz-research installed to $DEST"
echo "  Run /knz-research in any Claude Code session to start a research project."
