#!/usr/bin/env bash
set -euo pipefail

sample_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$sample_root"

workflows=(
  .github/workflows/hello-actions.yml
  .github/workflows/check-guidelines.yml
  .github/workflows/detect-source-change.yml
  .github/workflows/propose-guideline-update.yml
)

for workflow in "${workflows[@]}"; do
  if [[ ! -s "$workflow" ]]; then
    printf 'FAIL: workflow is missing or empty: %s\n' "$workflow" >&2
    exit 1
  fi
done

actionlint "${workflows[@]}" examples/*.yml

proposal_workflow=.github/workflows/propose-guideline-update.yml
grep -Fq "      old_hash: \${{ steps.compare.outputs.old_hash }}" "$proposal_workflow"
grep -Fq '    needs: detect' "$proposal_workflow"
grep -Fq "    if: needs.detect.outputs.changed == 'true'" "$proposal_workflow"
grep -Fq '      contents: read' "$proposal_workflow"
grep -Fq '      contents: write' "$proposal_workflow"
grep -Fq '      pull-requests: write' "$proposal_workflow"
grep -Fq '        run: bash scripts/propose-update.sh' "$proposal_workflow"

printf '%s\n' 'PASS: core workflows are present, valid, and connected'