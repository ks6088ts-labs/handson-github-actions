# 参照資料と検証範囲

[受講者 README に戻る](../README.md)

## 2026-09-09 に確認した公式資料

| 資料 | 確認した事項 |
| --- | --- |
| [Develop agentic workflows in GitHub Actions](https://docs.github.com/en/actions/tutorials/develop-agentic-workflows-in-github-actions) | Public Preview、source と lock、組織所有 repo の GITHUB_TOKEN 認証 |
| [Using GitHub Copilot](https://github.github.com/gh-aw/engines/copilot/) | Copilot エンジンの選択と認証。Playwright CLI / Firefox でも閲覧確認 |
| [GitHub Repository Checkout](https://github.github.com/gh-aw/reference/checkout/) | agent の既定 checkout と資格情報の扱い |
| [Safe Outputs](https://github.github.com/gh-aw/reference/safe-outputs/) | 別 job による書き込み、create-issue の上限、noop、失敗 Issue の制御 |
| [Cost Management](https://github.github.com/gh-aw/reference/cost-management/) | ルートの max-ai-credits と別枠の脅威検知上限、予算管理 |
| [Triggering a workflow](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow) | paths、手動トリガー、GITHUB_TOKEN 由来 PR の検査実行承認、必須チェックと paths の注意 |

公式サイトは更新されます。特に Preview の構文・認証・利用制限は、開催前に再確認してください。AIC の表示は推定を含むため、実際の請求は課金画面で確認します。

## あわせて読む公式資料

- [Workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax): YAML の全体構造。
- [Events that trigger workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows): schedule の条件・遅延など。
- [Secure use](https://docs.github.com/en/actions/reference/security/secure-use): 権限、入力、Action の SHA 固定。
- [About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners): 所有者チームの要件。
- [About rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets): ルールと利用プラン。
- [GitHub CLI: gh pr create](https://cli.github.com/manual/gh_pr_create): PR 作成の引数。
- [gh-aw Compilation Process](https://github.github.com/gh-aw/reference/compilation-process/): 生成物の仕組み。

## 使用した版

| 対象 | 版・固定値 |
| --- | --- |
| gh-aw | `v0.86.2` |
| actionlint | `v1.7.12` |
| ShellCheck | `0.9.0` |
| 基礎の checkout | `v5.0.0` → `08c6903cd8c0fde910a37f88322edcfb5dd907a8` |
| 任意サンプルの upload-artifact | `v4.6.2` → `ea165f8d65b6e75b540449e92b4886f43607fa02` |
| 任意サンプルの download-artifact | `v4.3.0` → `d3f86a106a0bac45b974a628896c90dbdf5c8093` |
| Advanced の Action / コンテナー | [生成 lock](../.github/workflows/guideline-impact-report.lock.yml) 冒頭の manifest に記録 |

基礎で使う3つの Action のタグは、公式リポジトリの `git ls-remote` で SHA を解決しました。Advanced は compiler が参照を解決するため、基礎と同じ Action の版になるとは限りません。更新時は挙動を再検証し、SHA だけを無条件に置換しないでください。

## 確認済みと未確認を分ける

**ローカルで確認済み**: 通常 workflow と任意サンプルの actionlint、shell の静的検査、初期ハッシュ一致、追記検知、見出し検査、不正入力・欠損の失敗、模擬 CLI を用いた PR 作成失敗からの復旧・重複防止・閉じた PR の扱い・main 不変・古い run の拒否。Advanced は独立した一時 Git リポジトリで compile し、再 compile の生成差分がないことを確認しています。

**実環境では未確認**: GitHub-hosted runner での完走、組織の CODEOWNERS / ruleset / 課金ポリシー、実 PR / Issue 作成、AI 出力品質、費用上限で実際に停止する動作、90分の運営リハーサル。GitHub 上の作成・公開・push や AI 利用は実施していません。開催前に [講師チェックリスト](instructor.md) で確認してください。

生成 lock のコンパイル成功は、AI の出力や組織環境での成功を保証しません。教材の PowerPoint はこのサンプル作成では編集・本文確認していません。

## ドキュメントの検査

サンプルのルートで実行します。これらは講師・メンテナー用で、参加者には不要です。

```bash
npx --yes markdownlint-cli2 README.md 'docs/*.md' 'examples/*.md'
npx --yes --package markdown-link-check markdown-link-check \
  --config tests/link-check.json README.md docs/*.md examples/*.md
```

リンク検査は Markdown パーサーを利用し、ローカルの相対リンクを確認します。外部 URL の疎通はこのコマンドから除外し、上記の公式資料確認とは区別しています。
