#!/usr/bin/env bash
set -euo pipefail

sample_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
validation_root=$(mktemp -d)
trap 'rm -rf "$validation_root"' EXIT
cp -R "$sample_root/.github" "$validation_root/"
cp "$sample_root/.gitattributes" "$validation_root/"
git -C "$validation_root" init -q
cd "$validation_root"
gh aw version
gh aw compile guideline-impact-report
cmp .github/workflows/guideline-impact-report.lock.yml "$sample_root/.github/workflows/guideline-impact-report.lock.yml"
gh aw compile guideline-impact-report
cmp .github/workflows/guideline-impact-report.lock.yml "$sample_root/.github/workflows/guideline-impact-report.lock.yml"
grep -Fq 'copilot-requests: none' .github/workflows/guideline-impact-report.md
grep -Fq "COPILOT_GITHUB_TOKEN: \${{ secrets.COPILOT_GITHUB_TOKEN }}" .github/workflows/guideline-impact-report.lock.yml
if grep -Fq 'max-ai-credits:' .github/workflows/guideline-impact-report.md; then
	printf '%s\n' 'FAIL: workflow must use the tested default AI Credits guardrails' >&2
	exit 1
fi
grep -Fq "GH_AW_MAX_AI_CREDITS: \${{ vars.GH_AW_DEFAULT_MAX_AI_CREDITS || '1000' }}" .github/workflows/guideline-impact-report.lock.yml
grep -Fq "GH_AW_MAX_AI_CREDITS: \${{ vars.GH_AW_DEFAULT_DETECTION_MAX_AI_CREDITS || '400' }}" .github/workflows/guideline-impact-report.lock.yml
if grep -Fq 'S2STOKENS: true' .github/workflows/guideline-impact-report.lock.yml; then
	printf '%s\n' 'FAIL: organization-billing authentication is enabled' >&2
	exit 1
fi
printf '%s\n' 'PASS: standalone compilation, unchanged lock, repeatable compilation, PAT authentication, default AIC guardrails'