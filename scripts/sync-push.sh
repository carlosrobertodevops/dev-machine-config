#!/usr/bin/env bash
set -e

cd "$HOME/dev-machine-config"
git add .
git commit -m "${1:-update configs}" || true
git push

echo "Alterações enviadas."
