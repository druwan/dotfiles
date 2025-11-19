#!/bin/bash

set -euo pipefail

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "[install.sh] - Installing Chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

echo "[install.sh] - Applying dotfiles"
init --apply "git@github.com:druwan/dotfiles.git"

exit 0
