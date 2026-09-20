# 参照資料と検証範囲

[受講者READMEに戻る](../README.md) | [Advanced](advanced.md) | [講師向け準備](instructor.md)

## 2026-09-20 に確認した公式資料

| 資料 | 確認した事項 |
| --- | --- |
| [Develop agentic workflows in GitHub Actions](https://docs.github.com/en/actions/tutorials/develop-agentic-workflows-in-github-actions) | Public Preview、sourceからlockへのcompile、組織所有リポジトリの `GITHUB_TOKEN` 認証 |
| [Using GitHub Copilot](https://github.github.com/gh-aw/engines/copilot/) | 本来推奨する組織課金と、現在使用する個人PATの認証要件 |
| [GitHub Repository Checkout](https://github.github.com/gh-aw/reference/checkout/) | agentの既定checkoutと資格情報の扱い |
| [Safe Outputs](https://github.github.com/gh-aw/reference/safe-outputs/) | 読み取り中心のagentと、書き込み権限を持つ別jobの分離 |
| [Cost Management](https://github.github.com/gh-aw/reference/cost-management/) | agent 1000 AIC、脅威検知400 AICの既定上限、実測と予算管理 |
| [Triggering a workflow](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow) | path filter、手動トリガー、`GITHUB_TOKEN` が作成したPRの検査実行承認 |
| [gh-aw v0.88.7](https://github.com/github/gh-aw/releases/tag/v0.88.7) | compilerの固定版とrelease内容 |

公式サイトは更新されます。特に Preview の構文・認証・利用制限は、開催前に再確認してください。AIC の表示は推定を含むため、実際の請求は課金画面で確認します。

組織所有リポジトリでは本来、組み込みの `GITHUB_TOKEN` と組織課金による集中管理が望ましい構成です。現環境では組織課金を利用できないため、このリポジトリは `copilot-requests: none` とrepository secret `COPILOT_GITHUB_TOKEN` を使うPAT構成だけを実行・検証しています。

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
| gh-aw | `v0.88.7` |
| actionlint | `v1.7.12` |
| ShellCheck | `0.9.0` |
| 基礎の checkout | `v5.0.0` → `08c6903cd8c0fde910a37f88322edcfb5dd907a8` |
| 任意サンプルの upload-artifact | `v4.6.2` → `ea165f8d65b6e75b540449e92b4886f43607fa02` |
| 任意サンプルの download-artifact | `v4.3.0` → `d3f86a106a0bac45b974a628896c90dbdf5c8093` |
| Advanced の Action / コンテナー | [生成 lock](../.github/workflows/guideline-impact-report.lock.yml) 冒頭の manifest に記録 |

表にある3つのActionのタグは、公式リポジトリの `git ls-remote` でSHAを解決しました。Advancedではcompilerが参照を解決するため、通常workflowと同じ版になるとは限りません。更新時は挙動を再検証し、SHAだけを置換しないでください。

## 確認済みと未確認を分ける

**ローカルで確認済み**: 基礎4 workflowと任意サンプルのactionlint、shellの静的検査、未実施の初期文書、初期ハッシュ一致、追記検知、見出し検査、不正入力・欠損の失敗、模擬CLIを用いたPR作成失敗からの復旧、重複防止、閉じたPR、`main` 不変、古いrunの拒否。Advancedは一時Gitリポジトリでmainと任意サンプルのPAT構成をcompileしています。組織課金での実行は確認していません。

**実環境で開催前に確認すること**: GitHub-hosted runnerでのStep 1-5、組織のCODEOWNERS、ruleset、Actions設定、Advancedの認証と課金、Issue作成、AI出力、90分の運営時間。[講師チェックリスト](instructor.md)に従い、参加者用とは別のリポジトリで確認します。

生成lockのcompile成功は、AI出力や組織環境での成功を保証しません。実runがない場合は成功済みと記載しません。

## ドキュメントの検査

サンプルのルートで実行します。これらは講師・メンテナー用で、参加者には不要です。

```bash
bash tests/validate-docs.sh
```

このスクリプトは全Markdownのlint、内部リンク、外部公式リンク、過去のrun URL、ルートに残った孤立sourceを検査します。内部リンクは `tests/link-check-internal.json`、外部リンクは `tests/link-check-external.json` で分けています。外部サイトの疎通成功は内容の正しさを保証しないため、開催前に上表の確認事項も読み直します。
