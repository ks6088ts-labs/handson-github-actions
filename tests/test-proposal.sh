#!/usr/bin/env bash
set -euo pipefail

sample_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT
mkdir -p "$test_root/work" "$test_root/bin" "$test_root/gh"
cp "$sample_root/tests/mock-gh.sh" "$test_root/bin/gh"
chmod +x "$test_root/bin/gh"
export PATH="$test_root/bin:$PATH"
export MOCK_GH_DIR="$test_root/gh"
export GITHUB_STEP_SUMMARY="$test_root/summary"
export GITHUB_SERVER_URL='https://example.invalid'
export GITHUB_REPOSITORY='training/sample'
export GITHUB_RUN_ID=123
export BASE_BRANCH=main
git init --bare -q "$test_root/origin.git"
git init -q -b main "$test_root/work"
cd "$test_root/work"
git config user.name 'Local test'
git config user.email 'test@example.invalid'
git remote add origin "$test_root/origin.git"
cp -R "$sample_root/sources" "$sample_root/guidelines" "$sample_root/scripts" .
git add .
git commit -qm initial
printf '\n' >> sources/aws-updates.md
cat "$sample_root/fixtures/aws-update-addition.md" >> sources/aws-updates.md
git add sources/aws-updates.md
git commit -qm 'mock source update'
git push -q origin main
GITHUB_SHA=$(git rev-parse HEAD)
OLD_HASH=$(< sources/.ingested-hash)
NEW_HASH=$(sha256sum sources/aws-updates.md | cut -d ' ' -f 1)
export GITHUB_SHA OLD_HASH NEW_HASH
if MOCK_FAIL_CREATE=true bash scripts/propose-update.sh > "$test_root/first.log" 2>&1; then
  printf '%s\n' 'FAIL: simulated API failure ignored' >&2
  exit 1
fi
candidate_sha=$(git rev-parse HEAD)
[[ "$(git --git-dir="$test_root/origin.git" rev-parse main)" == "$GITHUB_SHA" ]]
[[ "$(git show main:sources/.ingested-hash)" == "$OLD_HASH" ]]
[[ "$(< sources/.ingested-hash)" == "$NEW_HASH" ]]
[[ "$(git diff --name-only "$GITHUB_SHA" "$candidate_sha" | wc -l)" -eq 2 ]]
git switch -q --detach "$GITHUB_SHA"
bash scripts/propose-update.sh > "$test_root/retry.log" 2>&1
grep -q '/actions/runs/123' "$MOCK_GH_DIR/body"
[[ "$(wc -l < "$MOCK_GH_DIR/attempts")" -eq 2 ]]
bash scripts/propose-update.sh > "$test_root/duplicate.log" 2>&1
[[ "$(wc -l < "$MOCK_GH_DIR/attempts")" -eq 2 ]]
[[ "$(git --git-dir="$test_root/origin.git" for-each-ref --format='%(objectname)' refs/heads/proposal/)" == "$candidate_sha" ]]
printf 'CLOSED\thttps://example.invalid/training/sample/pull/1\n' > "$MOCK_GH_DIR/pr"
bash scripts/propose-update.sh > "$test_root/closed.log" 2>&1
grep -q '自動再作成しません' "$test_root/closed.log"
rm "$MOCK_GH_DIR/pr"
git switch -q main
printf '\n' >> guidelines/aws-security-guideline.md
git add guidelines/aws-security-guideline.md
git commit -qm 'another person updates main'
git push -q origin main
git switch -q --detach "$GITHUB_SHA"
if bash scripts/propose-update.sh > "$test_root/stale.log" 2>&1; then
  printf '%s\n' 'FAIL: stale run accepted' >&2
  exit 1
fi
grep -q '既定ブランチが更新' "$test_root/stale.log"
if NEW_HASH='$(touch injected)' bash scripts/propose-update.sh >/dev/null 2>&1; then
  printf '%s\n' 'FAIL: invalid hash accepted' >&2
  exit 1
fi
[[ ! -e injected ]]
printf '%s\n' 'PASS: failed-create recovery, duplicate/closed PR, immutable main, stale run, invalid input'