# Agentic Workflowを編集する

[Advancedに戻る](advanced.md) | [講師向け準備](instructor.md) | [公式資料](references.md)

この文書は講師・メンテナー向けです。受講者向け30分ルートには含めません。ローカルへcloneした独立した演習リポジトリで作業します。

## このリポジトリの認証方針

組織所有リポジトリでは、本来は組み込みの `GITHUB_TOKEN` と組織課金を使う構成が望ましいです。個人PATの所有者、有効期限、配布先を管理せずに済み、費用とポリシーを組織で統制できるためです。

現状は組織課金を利用できないため、このリポジトリの全Agentic WorkflowをPAT構成に固定します。source、生成lock、任意サンプル、検証スクリプトはPATだけを使用します。組織課金を利用できるようになり、別リポジトリで実runを検証するまでは `copilot-requests: write` へ戻しません。

| 構成 | frontmatter | secret | 現在の扱い |
| --- | --- | --- | --- |
| 個人PAT | `copilot-requests: none` | `COPILOT_GITHUB_TOKEN` | 配布・実行・検証に使用する |
| 組織課金 | `copilot-requests: write` | 不要 | 本来の推奨構成。現環境では使用しない |

2つの構成を混在させないでください。

### 個人PATを使う現在の構成

sourceの権限を次のようにします。

```yaml
permissions:
  contents: read
  copilot-requests: none
```

Copilot契約が有効な個人アカウントをresource ownerとし、Account permissionsのCopilot RequestsをReadにしたfine-grained PATを作成します。値をrepository secret `COPILOT_GITHUB_TOKEN` に登録してからcompileします。

PATの有効期限と所有者を記録します。token値を資料、チャット、ログ、Issueへ貼り付けないでください。

## authoring環境を準備する

```bash
gh --version
gh auth status
gh extension install github/gh-aw --pin v0.88.7
gh aw version
git switch -c practice/impact-prompt
```

拡張が導入済みならinstallは省略し、`gh aw version` が `v0.88.7` であることを確認します。GitHub CLIの認証が必要な場合は次を実行し、認証情報は端末の案内に従って入力します。

```bash
gh auth login --scopes repo,workflow
```

## sourceを編集してcompileする

1. [.github/workflows/guideline-impact-report.md](../.github/workflows/guideline-impact-report.md)だけを編集します。
2. 例として「Issueに含めること」へ「対応の優先度とその理由」を追加します。
3. sourceからlockを再生成します。

```bash
gh aw compile guideline-impact-report
git diff -- .github/workflows/guideline-impact-report.md \
  .github/workflows/guideline-impact-report.lock.yml \
  .github/aw/actions-lock.json
```

`.lock.yml` と `actions-lock.json` は生成物です。手で修正しません。sourceを変えたPRには、compileで変わった生成物も含めます。

## 差分をレビューする

- [ ] sourceの指示変更が意図どおりである。
- [ ] agentに `contents: write` と `issues: write` が追加されていない。
- [ ] Issue作成の上限が1件のままである。
- [ ] 許可するコマンドと入力ファイルが増えていない。
- [ ] Actionとコンテナーの参照に意図しない変更がない。
- [ ] sourceが `copilot-requests: none` のままである。
- [ ] 生成lockが `secrets.COPILOT_GITHUB_TOKEN` を参照している。
- [ ] AI利用上限、PAT所有者、費用負担を確認した。

次の検証は、mainと任意サンプルがPAT構成のままcompileできることを確認します。組織課金への変換は行いません。

```bash
bash tests/validate-advanced.sh
```

## PRでレビューする

```bash
git add .github/workflows/guideline-impact-report.md \
  .github/workflows/guideline-impact-report.lock.yml \
  .github/aw/actions-lock.json
git commit -m "docs: refine guideline impact report"
git push --set-upstream origin practice/impact-prompt
gh pr create --base main \
  --title "影響レポートの指示を改善" \
  --body "sourceと生成lockのレビューをお願いします。"
```

人がsourceと生成物をレビューし、PRをマージしてから手動実行します。実runで入力読取、Issue作成、ガイドライン本文不変、AI利用量を確認します。

## `init` と `compile` の使い分け

`gh aw compile` は既存sourceからlockを再生成します。このサンプルの編集にはこちらを使います。

`gh aw init` は、coding agentが新しいAgentic Workflowを作るためのskillsとinstructionsを追加します。完成済みサンプルの実行や再compileには必要ありません。
