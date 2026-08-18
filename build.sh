#!/bin/sh
# Bygger index.html (frittstående side) fra game.html (innholdsfilen).
# game.html inneholder <title>, <style> og resten av siden - uten <html>/<head>/<body>,
# slik at samme fil kan publiseres som Artifact og hostes som vanlig nettside.
set -e
cd "$(dirname "$0")"
CUT=$(grep -n '^</style>$' game.html | head -1 | cut -d: -f1)
{
  printf '%s\n' '<!doctype html>'
  printf '%s\n' '<html lang="nb">'
  printf '%s\n' '<head>'
  printf '%s\n' '<meta charset="utf-8" />'
  printf '%s\n' '<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover" />'
  printf '%s\n' '<meta name="theme-color" content="#05080F" />'
  printf '%s\n' '<meta name="description" content="Skrivespill for pugging: svar pa sporsmalet for asteroiden treffer jorden." />'
  printf '%s\n' '<link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>&#9732;</text></svg>" />'
  sed -n "1,${CUT}p" game.html
  printf '%s\n' '</head>'
  printf '%s\n' '<body>'
  sed -n "$((CUT+1)),\$p" game.html
  printf '%s\n' '</body>'
  printf '%s\n' '</html>'
} > index.html
echo "index.html bygget ($(wc -c < index.html) bytes)"
