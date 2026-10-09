#!/usr/bin/env bash
# Static checks for the site. CI runs this before every deploy, and it runs
# the same way locally:  bash scripts/check.sh
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0

# 1. Every local file index.html references exists.
refs=$(grep -oE '(src|href)="[^"]*"' index.html \
  | sed -E 's/^[a-z]+="(.*)"$/\1/' \
  | grep -vE '^(https?:|mailto:|#)' \
  | sort -u)
for ref in $refs; do
  [ -f "$ref" ] || { echo "missing file referenced by index.html: $ref"; fail=1; }
done

# 2. Every url() in the stylesheets points at a file that exists.
for css in assets/css/*.css; do
  dir=$(dirname "$css")
  for ref in $(grep -oE "url\(['\"]?[^)'\"]+" "$css" | sed -E "s/url\(['\"]?//" | sort -u); do
    case "$ref" in http:* | https:* | data:*) continue ;; esac
    [ -f "$dir/$ref" ] || { echo "missing file referenced by $css: $ref"; fail=1; }
  done
done

# 3. Nothing loads from a third-party origin: fonts are vendored and there is
#    no CDN. External <a href> links are navigation, so they are allowed.
if grep -nE 'src="https?://' index.html; then
  echo "external src in index.html"; fail=1
fi
if grep -nE '<link[^>]+href="https?://' index.html; then
  echo "external <link> in index.html"; fail=1
fi
if grep -nE "url\(['\"]?https?://|@import" assets/css/*.css; then
  echo "external url() or @import in the stylesheets"; fail=1
fi

# 4. Markup conventions: no inline styles and no placeholder links.
if grep -n 'style="' index.html; then
  echo "inline style in index.html (add a class in components.css instead)"; fail=1
fi
if grep -nE 'example\.com|href="#"' index.html; then
  echo "placeholder link in index.html"; fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "all checks passed"
fi
exit "$fail"
