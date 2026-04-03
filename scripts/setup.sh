#!/usr/bin/env bash
set -e

REPO_DIR="$HOME/dev-machine-config"

if [ ! -d "$REPO_DIR" ]; then
  echo "Repo não encontrado em $REPO_DIR"
  exit 1
fi

bash "$REPO_DIR/scripts/backup.sh"
bash "$REPO_DIR/scripts/link.sh"
bash "$REPO_DIR/scripts/install-deps.sh"
bash "$REPO_DIR/scripts/doctor.sh"

echo "Setup concluído."