#!/bin/zsh
set -euo pipefail

if [ $# -lt 1 ]; then
  echo -en "Error: missing new note name"
  exit 1
fi

# Combine all args into a single string
input="$*"

# lowercase-dash-separated-slug, filename & alias
slug=$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//;s/-$//')
filename="${slug}.md"

# Capitalize properly
title=$(echo "$input" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}')

inbox_path="$NOTES/0-Inbox"
note_path="$inbox_path/$filename"

export NVIM_TITLE="$title"
export NVIM_ALIAS="$slug"

if [ ! -f "$note_path" ]; then
  echo "# ${title}" > "$note_path"
fi

nvim "$note_path"

