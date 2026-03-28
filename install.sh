#!/bin/bash

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "To install the research-agent plugin, run:"
echo ""
echo "  claude plugin install $PLUGIN_DIR"
echo ""
echo "Then use /research:init in any Claude Code session to start a research project."
