#!/usr/bin/env bash

if [ $# -lt 1 ]; then
  echo -en "Error: Missing yt link(s)"
fi

links="$*"

for link in links; do echo -en "Downloading $link" && yt-dlp --format "bv*[ext=mp4]+ba[ext=m4a]/[ext=mp4" "$link" -o /tmp/; done
