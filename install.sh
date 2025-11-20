#!/bin/bash

set -euo pipefail

mkdir -p "$HOME/.local/bin"

BIN="$HOME/.local/bin"
DOTFILES_DIR="$HOME/dotfiles"

if command -v zsh >/dev/null; then
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "[install.sh] - Installing Chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN"
fi

echo "[install.sh] - Applying dotfiles"
"$BIN/chezmoi" init --apply --source="$DOTFILES_DIR"

exit 0
