# 任意学習のサンプル

[受講者READMEに戻る](../README.md) | [Agentic Workflowの編集](../docs/agentic-authoring.md)

基礎編とAdvancedの完了に、ここにあるサンプルは必要ありません。目的に合うものを1本だけ試します。

## 目的から選ぶ

| 学びたいこと | 種類 | サンプル | 実行結果・副作用 |
| --- | --- | --- | --- |
| 手動入力とshellの入力検証 | 通常Actions | [manual-task.yml](manual-task.yml) | 選んだフォルダーの一覧をログへ出す |
| 定期実行とタイムゾーン | 通常Actions | [daily-check.yml](daily-check.yml) | 時刻と変更有無を出す。PRは作らない |
| job間のファイル受け渡し | 通常Actions | [build-report.yml](build-report.yml) | Summaryとartifactを1件作る |
| 最小権限でIssueを作る | 通常Actions | [notify-by-issue.yml](notify-by-issue.yml) | 実行ごとにIssueを1件作る |
| AIでリポジトリ状況を整理する | Agentic Workflow | [agentic/daily-repo-status.md](agentic/daily-repo-status.md) | AI利用量を消費し、Issueを作る |

## 通常Actionsを試す

1. YAMLを1本選び、リポジトリの `.github/workflows/` へ同名で配置します。
2. 変更用ブランチからPRを作り、人がレビューしてマージします。
3. `Actions` で `Extra ...` を選び、まず `Run workflow` で実行します。
4. 期待結果を確認したら、定期実行を無効化するか、YAMLを削除するPRをマージします。

Web UIの `Add file` → `Create new file` でも配置できます。組織のAction許可リストは講師が確認します。

## 定期実行を読む

[daily-check.yml](daily-check.yml)はUTCの `17 0 * * 1-5` を使います。月曜日から金曜日のJST 09:17に相当します。祝日は除外しません。毎時0分の混雑を避ける例であり、時刻どおりの開始は保証されません。

| 想定時刻（JST） | UTC の cron |
| --- | --- |
| 毎日09:00 | `0 0 * * *` |
| 毎日18:30 | `30 9 * * *` |
| 月〜金09:17 | `17 0 * * 1-5` |

定期実行は既定ブランチのworkflowが対象です。マージした時点から自動実行の対象になります。試用後は `Actions` → `Extra Daily Check` → メニュー → `Disable workflow` で停止するか、YAMLを削除するPRをマージします。

## 入力と artifact の注意

入力は `${{ inputs.target }}` を `run` に直書きせず、`env` へ渡して引用符付きの `"$TARGET"` で読みます。CLIから想定外の値を渡されても、shell側の許可リストで拒否します。

jobは別のマシンで動くため、ファイルはそのまま共有されません。artifactをuploadして、次のjobでdownloadします。この例の保存期間は1日です。ログやartifactに秘密情報を入れないでください。

Issue通知は意図的に単純な例です。再実行のたびに1件増えます。作成後は人が内容を確認して閉じます。基礎編の候補PRとは異なり、重複を防止しません。

## Agentic Workflowを試す

[daily-repo-status.md](agentic/daily-repo-status.md)は手動実行から始めるsourceです。自動実行は設定していません。

このリポジトリでは組織課金を利用できないため、この任意サンプルもPATを使います。組織所有リポジトリでは本来は組織課金が望ましいものの、現環境では `copilot-requests: none` を維持します。

1. 講師がAdvancedの利用、認証、予算を許可していることを確認します。
2. 対象リポジトリにrepository secret `COPILOT_GITHUB_TOKEN` があることを講師が確認します。
3. `report` と `daily-status` のラベルを作成します。
4. sourceを `.github/workflows/daily-repo-status.md` へ配置します。
5. [編集とcompileの手順](../docs/agentic-authoring.md#sourceを編集してcompileする)でlockを生成します。
6. sourceと生成物をPRでレビューしてからマージします。
7. `Run workflow` で1回だけ実行し、IssueとAI利用量を確認します。

定期実行へ変える場合は、頻度と月間予算を先に決めます。試用後はworkflowを無効化するか、sourceとlockを削除するPRをマージします。

公式の根拠は[参照資料](../docs/references.md)にまとめています。
