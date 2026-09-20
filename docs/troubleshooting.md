# 困ったときの確認表

[受講者READMEに戻る](../README.md) | [Advanced](advanced.md)

最初に次の4点を記録します。

- workflowの名前
- runのURL
- 最初に赤くなったstep
- エラー文

ログやスクリーンショットにtokenやsecretを含めないでください。値を表示して確認する必要はありません。

## 開始前

| 見えている状況 | 最初に見る場所 | 次の操作 |
| --- | --- | --- |
| Actionsにworkflowがない | リポジトリのルート | `.github/workflows/` がリポジトリ直下にあるか講師が確認する |
| `Settings` が見えない | 講師が設定した権限 | 画面の有無で判断せず、講師にwrite権限を確認する |
| CODEOWNERSに `FIXME` がある | `.github/CODEOWNERS` | 講師が実在するチームへ置換してから配布する |
| 初回から「変更あり」になる | `main` の更新文書とハッシュ | 参加者は直さず、講師が未変更の初期コピーへ戻す |

## Step 1-2

| 見えている状況 | 最初に見る場所 | 次の操作 |
| --- | --- | --- |
| `Run workflow` がない | 既定ブランチのworkflow | `workflow_dispatch` と配置を講師が確認する |
| checkoutだけ失敗する | 最初に赤いstep | Actionの許可、GitHubへの通信、`contents: read` を講師が確認する |
| YAMLがInvalidになる | GitHubが示す行 | タブをスペースへ直し、完成版と比較する |
| `main` へ直接commitできない | `Commit changes` 画面 | 正常。新しいブランチを選んでPRを作る |
| 自分のPRを承認できない | PRの作成者 | 講師または別のレビュー担当者へ依頼する |
| H1がないと表示される | 検査ログのファイル名 | 先頭の `#`、半角スペース、見出しを戻して同じブランチへcommitする |
| `02` が起動しない | 変更したファイル | `guidelines/**/*.md` 以外だけの変更なら正常。対象ファイルを確認する |
| `02` が複数回動く | 各runのevent | push、pull request、マージ後のpushを区別する |

## Step 3-5

| 見えている状況 | 最初に見る場所 | 次の操作 |
| --- | --- | --- |
| 追記後も「変更なし」になる | `main` の更新文書 | 入力用PRのマージ後に、新しい `Run workflow` を実行する |
| `03` または `04` のjobがskipになる | 実行ブランチとSummary | `main` を選ぶ。`propose` だけのskipは変更なしなら正常 |
| 取込済みハッシュのエラーになる | `sources/.ingested-hash` | 64桁を手入力せず、講師が隠しファイルを含む初期コピーを復元する |
| `Resource not accessible` になる | `04` の失敗step | `contents`、`pull-requests`、組織ポリシーを講師が確認する |
| ActionsによるPR作成が禁止される | ActionsのGeneral設定 | `Allow GitHub Actions to create and approve pull requests` を講師が確認する |
| 既定ブランチが更新されたと表示される | `04` のログ | 古い `Re-run jobs` ではなく、新しい `Run workflow` を実行する |
| 再実行してもPRが増えない | Summary | 正常。既存PRのリンクを開く |
| 閉じた候補を再検討したい | 元の候補PR | 人が再openする。workflowは却下済み候補を自動再作成しない |
| Reviewersが空になる | `main` のCODEOWNERS | チーム名、可視性、write権限、設定エラーを講師が確認する |
| 候補PRの検査が承認待ちになる | PRのmerge box | write権限者が差分を確認して `Approve workflows to run` を選ぶ |
| 入力用PRがPendingのままになる | rulesetの必須check | path filter付き検査を全PRの必須checkにしていないか確認する |
| 承認後も「変更あり」になる | `main` の取込済みハッシュ | 正常。候補PRは当日マージしないため、基準値は古いまま |

## Advanced

| 見えている状況 | 最初に見る場所 | 次の操作 |
| --- | --- | --- |
| `COPILOT_GITHUB_TOKEN` がないと表示される | 対象リポジトリのActions secrets | secret名と登録先を確認する。sourceは `copilot-requests: none` のままにする |
| `HTTP 403 Authentication failed` になる | agentのログとPAT設定 | PAT所有者のCopilot契約、Copilot Requests: Read、有効期限を確認する |
| sourceが `copilot-requests: write` になっている | sourceと生成lock | 現環境では組織課金を使わない。`none` へ戻してcompileする |
| AI利用上限で終了する | `gh aw audit RUN_ID` | 実測AICと組織予算を比較し、講師が上限を決める |
| Issueが作られない | `noop`、`detection`、`safe_outputs` | 入力読取、脅威検知、ラベルを確認する。検査を外して迂回しない |
| 10分以内に終わらない | runの進行状況 | runを停止し、講師の事前runを使う見学ルートへ切り替える |
| lockがsourceと一致しない | `gh aw version` と差分 | `v0.88.7` で再compileし、生成物を手で直さない |

## 再実行の使い分け

入力を変えた場合は `Run workflow` を使います。新しい `main` の文書を取得します。

通信や設定エラーから復旧する場合は `Re-run jobs` を使います。同じ入力を再処理します。その間に `main` が進んだ場合、Step 4は安全のため停止します。新しい `Run workflow` を実行してください。

エラーを消すために `permissions: write-all` を付けたり、保護ルールを解除したり、secret をログへ出したりしないでください。
