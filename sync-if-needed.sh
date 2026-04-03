#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$HOME/dev-machine-config"

COMPARE_SCRIPT="$PROJECT_ROOT/scripts/compare.sh"

if bash "$COMPARE_SCRIPT"; then
  echo
  echo "Nada para sincronizar. Abortando."
  exit 0
fi

echo
echo "Há diferenças. Prosseguindo com sincronização..."
