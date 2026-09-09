# 困ったときの確認表

[受講者 README に戻る](../README.md)

最初に **workflow の名前 / run の URL / 最初に赤くなった step / エラー文** を確認します。スクリーンショットやログを共有する際も秘密情報は含めません。token や secret の値を表示して確認する必要はありません。

| 状況 | 確認する場所 | 対処 | 再確認 |
| --- | --- | --- | --- |
| Actions に一覧がない | repo のルート | サンプルがサブフォルダーに入っていないか講師に確認 | `.github/workflows/` が repo 直下にある |
| Run workflow がない | 既定ブランチ上の YAML | `workflow_dispatch` と配置を確認 | main の Actions でボタンが出る |
| 01 のみ実行できる | checkout を使う step | Action の許可、GitHub への通信、contents: read を講師が確認 | checkout が成功する |
| YAML が Invalid | GitHub が示す行 | タブを使わずスペースで修正。完成版と比較する | PR のチェックが更新される |
| main へ直接コミットできない | Commit changes の画面 | 正常。新しいブランチを選んで PR を作る | レビュー依頼ができる |
| 自分の PR を承認できない | PR の作成者 | 講師または別の担当者に依頼 | 他者の承認記録が残る |
| H1 がない | 検査ログに出たファイル | 先頭に `#` と半角スペースと見出しを戻し、同じ変更ブランチへコミット | 検査が成功する |
| 02 が起動しない | 変更ファイル一覧 | 更新文書だけなら正常。ガイドライン変更か確認 | 対象 Markdown を変更すると起動 |
| 02 が複数回動く | run の event | push と PR、マージ後の push は別イベント | 同じ変更による run か見分ける |
| 初回から変更あり | main の更新文書とハッシュ | 初期コピーか講師に確認。参加者はハッシュを直さない | 未変更のコピーで変更なし |
| 追記したのに変更なし | main の更新文書 | 入力用 PR のマージと、新しい Run workflow を確認 | 新しい run で変更あり |
| 03 / 04 の job が skip | 実行ブランチ | main を選ぶ。04 の propose だけ skip なら変更なしで正常 | Summary と実行ブランチを確認 |
| 取込済みハッシュのエラー | sources の初期ファイル | 隠しファイルも配置したか確認。64桁を手入力しない | 講師が初期コピーで再検証 |
| Resource not accessible | 04 の失敗 step | job の contents / pull-requests 権限と組織ポリシーを講師が確認 | 再実行で成功 |
| Actions is not permitted to create... | Actions の General 設定 | PR 作成許可を講師が確認 | 同じ run を再実行し PR が作られる |
| 既定ブランチが更新された | 04 のログ | 古い Re-run jobs ではなく、新しい Run workflow を使う | 最新 main で検知される |
| 04 を実行しても PR が増えない | Summary の既存 PR リンク | 正常。同じ更新は同じ PR を使う | 既存 PR を開ける |
| 閉じた候補をもう一度検討したい | 元の候補 PR | 人が再オープン。自動で却下判断を覆さない | 元の PR でレビューを再開 |
| CODEOWNERS の要求がない | main の CODEOWNERS | FIXME、可視チーム、write 権限、所有者設定エラーを講師が確認 | 新しい該当 PR で要求が出る |
| Checks に生成元 run がない | PR 本文 | 「生成元の実行ログ」リンクを開く | 04 の run に戻れる |
| PR 検査が承認待ち | PR の merge box | 差分を確認した write 権限者が Approve workflows to run | 検査が開始される |
| 入力用 PR が Pending のまま | ruleset の必須 checks | path filter で起動しないチェックを全 PR に必須化していないか講師が確認 | 人のレビュー後にマージできる |
| 承認後も変更あり | main の取込済みハッシュ | 正常。候補 PR は当日はマージしない | 候補ブランチだけハッシュが新しい |
| compile が max-ai-credits で失敗 | frontmatter | engine の内側ではなくルートに置く | v0.86.2 で compile 成功 |
| Advanced が認証・課金で停止 | agent / activation のログ | 組織管理者がポリシーと予算を確認。当日は見学へ | 許可された講師 run で再確認 |
| AI 上限で終了した | agent / detection のログ | 個別上限と実際の利用量を確認。無断で引き上げない | 講師が予算の範囲で判断 |
| Advanced の Issue がない | noop / detection / safe_outputs | 入力読取、検証拒否、ラベル設定を確認。脅威検知を外して迂回しない | 原因を解消した講師 run を確認 |
| lock が一致しない | gh aw version と差分 | 指示変更後に同じ版で再 compile。生成物は手書きしない | source と lock を同じ PR でレビュー |

## 再実行の使い分け

**入力を変えた場合は `Run workflow`。** 新しい main の文書を取得します。

**通信や設定エラーから復旧する場合は `Re-run jobs`。** 同じ入力を再処理します。ただし、その間に main が進んだ場合は04が停止するので、新しく実行してください。長期間経過した古い run の再利用は避けます。

エラーを消すために `permissions: write-all` を付けたり、保護ルールを解除したり、secret をログへ出したりしないでください。
