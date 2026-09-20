#!/usr/bin/env bash
set -euo pipefail

sample_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$sample_root"

documents_file=$(mktemp)
trap 'rm -f "$documents_file"' EXIT
find . -type f -name '*.md' -not -path './.git/*' -print0 > "$documents_file"

xargs -0 npx --yes markdownlint-cli2 < "$documents_file"

while IFS= read -r -d '' document; do
  npx --yes --package markdown-link-check markdown-link-check \
    --quiet --config tests/link-check-internal.json "$document"
done < "$documents_file"

while IFS= read -r -d '' document; do
  npx --yes --package markdown-link-check markdown-link-check \
    --quiet --config tests/link-check-external.json "$document"
done < "$documents_file"

if grep -R -E 'https://github\.com/[^/]+/[^/]+/actions/runs/[0-9]+' \
  --include='*.md' --exclude-dir=.git .; then
  printf '%s\n' 'FAIL: workshop content contains a historical workflow run URL' >&2
  exit 1
fi

if [[ -e daily-repo-status.md ]]; then
  printf '%s\n' 'FAIL: optional Agentic Workflow source remains at the repository root' >&2
  exit 1
fi

printf '%s\n' 'PASS: Markdown, internal links, external links, and distribution hygiene'
