#!/usr/bin/env bash
set -euo pipefail

document_count=0
while IFS= read -r -d '' document; do
  document_count=$((document_count + 1))
  if ! grep -q '^# ' "$document"; then
    printf 'H1 見出し (# ) がありません: %s\n' "$document" >&2
    exit 1
  fi
done < <(find guidelines -type f -name '*.md' -print0)
if [[ $document_count -eq 0 ]]; then
  printf '%s\n' '検査対象の Markdown がありません。' >&2
  exit 1
fi
printf '検査成功: %s ファイル\n' "$document_count"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  printf '## ガイドライン検査結果\n\n- 検査成功: %s ファイル\n' "$document_count" >> "$GITHUB_STEP_SUMMARY"
fi