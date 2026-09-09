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
printf '%s\n' 'PASS: standalone compilation, unchanged lock, repeatable compilation'