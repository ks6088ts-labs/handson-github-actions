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
cmp .github/aw/actions-lock.json "$sample_root/.github/aw/actions-lock.json"
gh aw compile guideline-impact-report
cmp .github/workflows/guideline-impact-report.lock.yml "$sample_root/.github/workflows/guideline-impact-report.lock.yml"
cmp .github/aw/actions-lock.json "$sample_root/.github/aw/actions-lock.json"
grep -Fq 'copilot-requests: none' .github/workflows/guideline-impact-report.md
grep -Fq '総合所見で「影響候補なし」と明記してください。' .github/workflows/guideline-impact-report.md
grep -Fq 'Issue のタイトルにも' .github/workflows/guideline-impact-report.md
grep -Eq '^      copilot-requests: none$' .github/workflows/guideline-impact-report.lock.yml
grep -Fq "COPILOT_GITHUB_TOKEN: \${{ secrets.COPILOT_GITHUB_TOKEN }}" .github/workflows/guideline-impact-report.lock.yml
grep -Fq 'issues: write' .github/workflows/guideline-impact-report.lock.yml
if grep -Fq 'contents: write' .github/workflows/guideline-impact-report.lock.yml; then
	printf '%s\n' 'FAIL: generated workflow grants contents write access' >&2
	exit 1
fi
if grep -Eq '^      copilot-requests: write$' .github/workflows/guideline-impact-report.lock.yml || \
	grep -Fq 'S2STOKENS: true' .github/workflows/guideline-impact-report.lock.yml; then
	printf '%s\n' 'FAIL: PAT workflow also enables organization billing' >&2
	exit 1
fi
if grep -Fq 'max-ai-credits:' .github/workflows/guideline-impact-report.md; then
	printf '%s\n' 'FAIL: workflow must use the tested default AI Credits guardrails' >&2
	exit 1
fi
grep -Fq "GH_AW_MAX_AI_CREDITS: \${{ vars.GH_AW_DEFAULT_MAX_AI_CREDITS || '1000' }}" .github/workflows/guideline-impact-report.lock.yml
grep -Fq "GH_AW_MAX_AI_CREDITS: \${{ vars.GH_AW_DEFAULT_DETECTION_MAX_AI_CREDITS || '400' }}" .github/workflows/guideline-impact-report.lock.yml
cp "$sample_root/examples/agentic/daily-repo-status.md" .github/workflows/
gh aw compile daily-repo-status
grep -Fq 'copilot-requests: none' .github/workflows/daily-repo-status.md
grep -Eq '^      copilot-requests: none$' .github/workflows/daily-repo-status.lock.yml
grep -Fq "COPILOT_GITHUB_TOKEN: \${{ secrets.COPILOT_GITHUB_TOKEN }}" .github/workflows/daily-repo-status.lock.yml
if grep -Eq '^      copilot-requests: write$' .github/workflows/daily-repo-status.lock.yml || \
	grep -Fq 'S2STOKENS: true' .github/workflows/daily-repo-status.lock.yml; then
	printf '%s\n' 'FAIL: optional PAT workflow also enables organization billing' >&2
	exit 1
fi
printf '%s\n' 'PASS: repeatable PAT compilation, optional example, least privilege, default AIC guardrails'