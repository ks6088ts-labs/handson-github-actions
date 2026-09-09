#!/usr/bin/env bash
set -euo pipefail

source_file="sources/aws-updates.md"
hash_file="sources/.ingested-hash"
if [[ ! -f "$source_file" || ! -f "$hash_file" ]]; then
  printf '%s\n' '更新文書または取込済みハッシュがありません。初期ファイルを確認してください。' >&2
  exit 1
fi
new_hash=$(sha256sum "$source_file" | cut -d ' ' -f 1)
old_hash=$(< "$hash_file")
if [[ ! "$old_hash" =~ ^[0-9a-f]{64}$ ]]; then
  printf '%s\n' '取込済みハッシュは SHA-256 の64桁で指定してください。' >&2
  exit 1
fi
changed=false
result='変更なし'
if [[ "$new_hash" != "$old_hash" ]]; then
  changed=true
  result='変更あり'
fi
printf 'changed=%s\nold_hash=%s\nnew_hash=%s\n' "$changed" "$old_hash" "$new_hash" | tee -a "${GITHUB_OUTPUT:-/dev/null}"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  printf "## %s\n\n- 取込済み: \`%s\`\n- 現在: \`%s\`\n" "$result" "$old_hash" "$new_hash" >> "$GITHUB_STEP_SUMMARY"
fi