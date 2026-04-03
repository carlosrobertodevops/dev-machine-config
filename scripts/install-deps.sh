#!/usr/bin/env bash
set -e

if command -v brew >/dev/null 2>&1; then
  [ -f "$HOME/dev-machine-config/Brewfile" ] && brew bundle --file="$HOME/dev-machine-config/Brewfile"
fi

echo "Dependências instaladas."
