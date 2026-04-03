#!/usr/bin/env bash
set -e

mkdir -p "$HOME/.config"

ln -sfn "$HOME/dev-machine-config/opencode" "$HOME/.config/opencode"
ln -sfn "$HOME/dev-machine-config/claude" "$HOME/.claude"

echo "Symlinks criados."