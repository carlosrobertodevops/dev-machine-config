#!/usr/bin/env bash
set -e

rm -f "$HOME/.config/opencode"
rm -f "$HOME/.claude"

mkdir -p "$HOME/.config/opencode"
mkdir -p "$HOME/.claude"

rsync -a "$HOME/dev-machine-config/opencode/" "$HOME/.config/opencode/"
rsync -a "$HOME/dev-machine-config/claude/" "$HOME/.claude/"

echo "Configurações restauradas em diretórios físicos."