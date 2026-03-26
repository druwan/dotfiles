#!/bin/bash
# rename-files.sh
# Dry run by default, pass --apply to rename

if [[ -z "$1" ]]; then
  echo "Usage: $0 <path> [--apply]"
  exit 1
fi

TARGET_PATH="$1"
DRY_RUN=true
[[ "$2" == "--apply" ]] && DRY_RUN=false

if [[ ! -d "$TARGET_PATH" ]]; then
  echo "Error: '$TARGET_PATH' is not a valid directory"
  exit 1
fi

santize() {
  echo "$1" | python3 -c "
import sys
import unicodedata
s = sys.stdin.read().strip()
s = unicodedata.normalize('NFC', s)
replacements = {
    '\u00e5': 'a', '\u00e4': 'a', '\u00f6': 'o',
    '\u00c5': 'A', '\u00c4': 'A', '\u00d6': 'O',
    ' ': '-',
    '.-': '.',
    '_': '-',
}
for old, new in replacements.items():
    s = s.replace(old, new)
while '--' in s:
    s = s.replace('--', '-')
print(s)
"
}

rename_path() {
  local old="$1"
  local dir
  local base
  dir=$(dirname "$old")
  base=$(basename "$old")

  new=$(santize "$base")

  if [[ "$base" != "$new" ]]; then
    echo "$old → $dir/$new"
    if [[ "$DRY_RUN" == false ]]; then
      mv "$old" "$dir/$new"
    fi
  fi
}

# Process deepest files first, then directories
while IFS= read -r -d '' path; do
  rename_path "$path"
done < <(find "$TARGET_PATH" -depth -print0)
