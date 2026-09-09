#!/usr/bin/env bash
set -euo pipefail

: "${BASE_BRANCH:?}" "${NEW_HASH:?}" "${OLD_HASH:?}" "${GITHUB_SHA:?}"
: "${GITHUB_SERVER_URL:?}" "${GITHUB_REPOSITORY:?}" "${GITHUB_RUN_ID:?}"
[[ "$NEW_HASH" =~ ^[0-9a-f]{64}$ && "$OLD_HASH" =~ ^[0-9a-f]{64}$ ]]
[[ "$GITHUB_SHA" =~ ^[0-9a-f]{40}$ && "$GITHUB_RUN_ID" =~ ^[0-9]+$ ]]
git check-ref-format "refs/heads/$BASE_BRANCH" >/dev/null
[[ "$(sha256sum sources/aws-updates.md | cut -d ' ' -f 1)" == "$NEW_HASH" ]]
[[ "$(< sources/.ingested-hash)" == "$OLD_HASH" ]]
[[ "$NEW_HASH" != "$OLD_HASH" ]]
proposal_key=$(printf '%s\n' "$BASE_BRANCH" "$OLD_HASH" "$NEW_HASH" | sha256sum | cut -d ' ' -f 1)
branch="proposal/aws-update-$proposal_key"
existing=$(gh pr list --repo "$GITHUB_REPOSITORY" --head "$branch" --base "$BASE_BRANCH" --state all --json state,url --jq '.[0] // empty | [.state, .url] | @tsv')
if [[ -n "$existing" ]]; then
  IFS=$'\t' read -r pr_state pr_url <<< "$existing"
  printf '既存 PR (%s): %s\n' "$pr_state" "$pr_url" | tee -a "${GITHUB_STEP_SUMMARY:-/dev/null}"
  if [[ "$pr_state" == CLOSED ]]; then
    printf '%s\n' '却下済みの候補は自動再作成しません。必要なら人が PR を再オープンしてください。' | tee -a "${GITHUB_STEP_SUMMARY:-/dev/null}"
  fi
  exit 0
fi
git fetch origin "refs/heads/$BASE_BRANCH"
if [[ "$(git rev-parse FETCH_HEAD)" != "$GITHUB_SHA" ]]; then
  printf '%s\n' '既定ブランチが更新されています。古い run の再実行ではなく Run workflow で新しく実行してください。' >&2
  exit 1
fi
run_url="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
body_file=$(mktemp)
trap 'rm -f "$body_file"' EXIT
{
  printf '## 人の確認が必要な更新候補\n\n'
  printf 'これは架空データの機械的な変更通知です。内容の正しさや反映要否は判定していません。\n\n'
  printf -- '- [生成元の実行ログ](%s)\n' "$run_url"
  printf -- '- [検知した更新文書](%s/%s/blob/%s/sources/aws-updates.md)\n' "$GITHUB_SERVER_URL" "$GITHUB_REPOSITORY" "$GITHUB_SHA"
  printf -- "- 元コミット: \`%s\`\n- 旧ハッシュ: \`%s\`\n- 新ハッシュ: \`%s\`\n\n" "$GITHUB_SHA" "$OLD_HASH" "$NEW_HASH"
  printf 'Files changed で候補を確認してください。自動マージはしません。演習では承認までで終了します。\n'
} > "$body_file"
remote_branch=$(git ls-remote --heads origin "refs/heads/$branch")
if [[ -z "$remote_branch" ]]; then
  git switch -c "$branch" "$GITHUB_SHA"
  git config user.name 'github-actions[bot]'
  git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
  {
    printf '\n## 更新候補（人の確認待ち）\n\n'
    printf '模擬更新文書に変更が検出されました。反映要否と本文をレビューしてください。\n\n'
    printf -- "- 元コミット: \`%s\`\n- [実行ログ](%s)\n" "$GITHUB_SHA" "$run_url"
  } >> guidelines/aws-security-guideline.md
  printf '%s\n' "$NEW_HASH" > sources/.ingested-hash
  git add guidelines/aws-security-guideline.md sources/.ingested-hash
  git commit -m 'chore: propose guideline update from source change'
  git push origin "HEAD:refs/heads/$branch"
fi
pr_url=$(gh pr create --repo "$GITHUB_REPOSITORY" --base "$BASE_BRANCH" --head "$branch" \
  --title 'AWS更新に伴うガイドライン更新候補（演習）' --body-file "$body_file")
printf '更新候補 PR: %s\n' "$pr_url" | tee -a "${GITHUB_STEP_SUMMARY:-/dev/null}"