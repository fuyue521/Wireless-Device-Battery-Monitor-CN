#!/usr/bin/env bash
# Fails when the version number drifts between the places that carry it.
#
# The version lives in four spots: !define APP_VERSION in the NSIS script (names the installer),
# FILEVERSION and PRODUCTVERSION in res/app.rc (what Explorer's file properties show), and the
# FileVersion/ProductVersion strings right under them. CI runs this on every push, and release.yml
# runs it again with the tag so "v1.0.7" can never publish a 1.0.6 package.
#
# Usage: scripts/check-version.sh [tag]     e.g. scripts/check-version.sh v1.0.6
#
# Exit codes: 0 = consistent, 1 = drift or missing value, 2 = a file could not be read.

set -euo pipefail

cd "$(dirname "$0")/.."

nsi_file=$(ls installer/*.nsi 2>/dev/null | head -n1 || true)
rc_file=res/app.rc
if [ -z "$nsi_file" ] || [ ! -f "$nsi_file" ] || [ ! -f "$rc_file" ]; then
  echo "error: expected $rc_file and installer/*.nsi in $(pwd)" >&2
  exit 2
fi

# "!define APP_VERSION "1.0.6""
nsi_app=$(sed -n 's/^[[:space:]]*!define[[:space:]][[:space:]]*APP_VERSION[[:space:]][[:space:]]*"\([^"]*\)".*/\1/p' "$nsi_file" | head -n1)
# "FILEVERSION 1,0,6,0" -> "1.0.6"
rc_filever=$(sed -n 's/^[[:space:]]*FILEVERSION[[:space:]][[:space:]]*\([0-9][0-9]*\),\([0-9][0-9]*\),\([0-9][0-9]*\),.*/\1.\2.\3/p' "$rc_file" | head -n1)
rc_prodver=$(sed -n 's/^[[:space:]]*PRODUCTVERSION[[:space:]][[:space:]]*\([0-9][0-9]*\),\([0-9][0-9]*\),\([0-9][0-9]*\),.*/\1.\2.\3/p' "$rc_file" | head -n1)
str_filever=$(sed -n 's/.*VALUE[[:space:]][[:space:]]*"FileVersion"[[:space:]]*,[[:space:]]*"\([^"]*\)".*/\1/p' "$rc_file" | head -n1)
str_prodver=$(sed -n 's/.*VALUE[[:space:]][[:space:]]*"ProductVersion"[[:space:]]*,[[:space:]]*"\([^"]*\)".*/\1/p' "$rc_file" | head -n1)

status=0
check() {  # name, value
  if [ -z "$2" ]; then
    echo "error: $1 is missing" >&2
    status=1
  fi
}

check "APP_VERSION in $nsi_file" "$nsi_app"
check "FILEVERSION in $rc_file" "$rc_filever"
check "PRODUCTVERSION in $rc_file" "$rc_prodver"
check "FileVersion string in $rc_file" "$str_filever"
check "ProductVersion string in $rc_file" "$str_prodver"
[ "$status" -eq 0 ] || exit "$status"

printf '%-42s %s\n' "installer APP_VERSION" "$nsi_app"
printf '%-42s %s\n' "res/app.rc FILEVERSION" "$rc_filever"
printf '%-42s %s\n' "res/app.rc PRODUCTVERSION" "$rc_prodver"
printf '%-42s %s\n' "res/app.rc FileVersion string" "$str_filever"
printf '%-42s %s\n' "res/app.rc ProductVersion string" "$str_prodver"

same() {  # name, value, reference-name, reference
  if [ "$2" != "$4" ]; then
    echo "error: $1 is $2 but $3 is $4" >&2
    status=1
  fi
}

same "FILEVERSION" "$rc_filever" "installer APP_VERSION" "$nsi_app"
same "PRODUCTVERSION" "$rc_prodver" "installer APP_VERSION" "$nsi_app"
same "FileVersion string" "$str_filever" "installer APP_VERSION" "$nsi_app"
same "ProductVersion string" "$str_prodver" "installer APP_VERSION" "$nsi_app"

if [ "$#" -ge 1 ] && [ -n "${1:-}" ]; then
  tag=${1#v}
  printf '%-42s %s\n' "tag" "$tag"
  same "tag" "$tag" "installer APP_VERSION" "$nsi_app"
fi

if [ "$status" -ne 0 ]; then
  echo "error: the version number is inconsistent; bump all of the places above together" >&2
  exit 1
fi
echo "ok: version $nsi_app is consistent everywhere${1:+ (tag $1)}"
