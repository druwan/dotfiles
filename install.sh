#!/bin/bash

set -euo pipefail

mkdir -p "$HOME/.local/bin"

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "[install.sh] - Installing Chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

echo "[install.sh] - Applying dotfiles"
"$HOME/.local/bin/chezmoi" init --apply --source="$PWD"

exit 0
