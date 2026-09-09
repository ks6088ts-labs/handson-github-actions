#!/usr/bin/env bash
set -euo pipefail

shopt -s globstar nullglob
documents=(guidelines/**/*.md)
if [[ ${#documents[@]} -eq 0 ]]; then
  printf '%s\n' '検査対象の Markdown がありません。' >&2
  exit 1
fi
for document in "${documents[@]}"; do
  if ! grep -q '^# ' "$document"; then
    printf 'H1 見出し (# ) がありません: %s\n' "$document" >&2
    exit 1
  fi
done
printf '検査成功: %s ファイル\n' "${#documents[@]}"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  printf '## ガイドライン検査結果\n\n- 検査成功: %s ファイル\n' "${#documents[@]}" >> "$GITHUB_STEP_SUMMARY"
fi