#!/bin/sh
# Bygger index.html (frittstående side) fra game.html (innholdsfilen).
#
# Steg 1: speiler sett/*.txt inn i RESERVE-blokken i game.html, slik at
#         reservekopiene aldri blir utdaterte.
# Steg 2: pakker game.html i <!doctype html> osv. og skriver index.html.
#
# game.html inneholder <title>, <style> og resten av siden - uten
# <html>/<head>/<body>, slik at samme fil kan publiseres som Artifact og
# hostes som vanlig nettside.
set -e
cd "$(dirname "$0")"

# ---------- steg 1: sett/*.txt  ->  RESERVE i game.html ----------
for f in sett/*.txt; do
  [ -e "$f" ] || continue
  id=$(basename "$f" .txt)

  # En backtick eller ${ i teksten ville brutt template-literalen i JavaScript.
  if grep -q '`' "$f" || grep -q '\${' "$f"; then
    echo "STOPP: $f inneholder backtick eller dollar-krollparentes - fjern det og bygg pa nytt." >&2
    exit 1
  fi
  if ! grep -q "=== $id START ===" game.html; then
    echo "Hopper over $f (ingen RESERVE-blokk for '$id' i game.html)"
    continue
  fi

  awk -v id="$id" -v fil="$f" '
    $0 ~ ("=== " id " START ===") {
      print
      n = 0
      while ((getline linje < fil) > 0) lines[n++] = linje
      close(fil)
      for (i = 0; i < n; i++) {
        pre  = (i == 0)     ? "  " id ": `" : ""
        post = (i == n - 1) ? "`,"          : ""
        print pre lines[i] post
      }
      hopp = 1
      next
    }
    $0 ~ ("=== " id " SLUTT ===") { hopp = 0 }
    hopp { next }
    { print }
  ' game.html > game.html.ny && mv game.html.ny game.html
done

# ---------- steg 2: game.html -> index.html ----------
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

for f in sett/*.txt; do
  [ -e "$f" ] || continue
  printf '  %-24s %s spørsmål\n' "$f" "$(grep -c '[^[:space:]]' "$f")"
done
echo "index.html bygget ($(wc -c < index.html) bytes)"
