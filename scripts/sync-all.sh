#!/usr/bin/env bash
set -e

cd "$HOME/dev-machine-config"
git pull --rebase

mkdir -p "$HOME/.config"
ln -sfn "$HOME/dev-machine-config/opencode" "$HOME/.config/opencode"
ln -sfn "$HOME/dev-machine-config/claude" "$HOME/.claude"

echo "Tudo sincronizado."