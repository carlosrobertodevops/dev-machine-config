#!/usr/bin/env bash
set -e

echo "Verificando symlinks..."
ls -ld "$HOME/.config/opencode" || true
ls -ld "$HOME/.claude" || true

echo
echo "Destino real:"
readlink "$HOME/.config/opencode" || true
readlink "$HOME/.claude" || true

echo
echo "Git status:"
cd "$HOME/dev-machine-config" && git status --short