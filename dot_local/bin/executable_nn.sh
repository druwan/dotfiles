#!/bin/zsh
set -euo pipefail

if [ $# -lt 1 ]; then
  echo -en "Error: missing new note name"
  exit 1
fi

# Combine all args into a single string
input="$*"

# Let python handle lowercase-dash-separated-slug, filename & alias
read -r slug title <<< $(python3 -c "
import re, sys

def deswedify(s: str) -> str:
  return s.replace('Å','a').replace('Ä','a').replace('Ö','o').replace('å','a').replace('ä','a').replace('ö','o')

def slugify(s: str) -> str:
    s = deswedify(s).lower()
    s = re.sub(r'[^a-z0-9]+', '-', s)
    return s.strip('-')


inp = '$input'
slug = slugify(inp)
title = inp.title()
print(slug, title)
")

filename="${slug}.md"
inbox_path="$NOTES/Inbox"
note_path="$inbox_path/$filename"

export NVIM_TITLE="$title"
export NVIM_SLUG="$slug"
export NVIM_ALIAS="$(date '+%Y-%m-%d')_${slug}"

touch "$note_path"
nvim "$note_path"
