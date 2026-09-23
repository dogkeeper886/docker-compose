#!/usr/bin/env bash
#
# Render every diagram to PNG for embedding in the README.
# Requires librsvg (rsvg-convert). Usage: ./docs/diagrams/render.sh
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p png
for svg in *.svg; do
  rsvg-convert -z 2 "$svg" -o "png/${svg%.svg}.png"
  echo "png/${svg%.svg}.png"
done
