#!/usr/bin/env bash
set -euo pipefail

sample_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT
cp -R "$sample_root/sources" "$sample_root/guidelines" "$sample_root/scripts" "$test_root/"
cd "$test_root"
export GITHUB_OUTPUT="$test_root/outputs"
export GITHUB_STEP_SUMMARY="$test_root/summary"
bash scripts/check-guidelines.sh
mkdir -p guidelines/nested
printf '# Nested\n' > 'guidelines/nested/with space.md'
bash scripts/check-guidelines.sh
printf 'Missing heading\n' > guidelines/nested/invalid.md
if bash scripts/check-guidelines.sh >/dev/null 2>&1; then
  printf '%s\n' 'FAIL: missing heading accepted' >&2
  exit 1
fi
rm guidelines/nested/invalid.md
bash scripts/compare-source.sh | grep -qx 'changed=false'
grep -q '変更なし' "$GITHUB_STEP_SUMMARY"
baseline=$(< sources/.ingested-hash)
printf '\n' >> sources/aws-updates.md
cat "$sample_root/fixtures/aws-update-addition.md" >> sources/aws-updates.md
bash scripts/compare-source.sh | grep -qx 'changed=true'
[[ "$(< sources/.ingested-hash)" == "$baseline" ]]
grep -q '変更あり' "$GITHUB_STEP_SUMMARY"
printf '%s\n' 'invalid' > sources/.ingested-hash
if bash scripts/compare-source.sh >/dev/null 2>&1; then
  printf '%s\n' 'FAIL: malformed hash accepted' >&2
  exit 1
fi
printf '%s\n' "$baseline" > sources/.ingested-hash
rm sources/aws-updates.md
if bash scripts/compare-source.sh >/dev/null 2>&1; then
  printf '%s\n' 'FAIL: missing source accepted' >&2
  exit 1
fi
printf '%s\n' 'PASS: initial state, change detection, immutable baseline, invalid hash, missing source'