# 任意学習のサンプル

[受講者 README に戻る](../README.md)

ここにある YAML は、そのままでは動きません。**試す1本だけ**をリポジトリの `.github/workflows/` へ同名でコピーし、変更用ブランチから PR を作って人がレビュー・マージします。Web UI の `Add file` → `Create new file` で配置しても構いません。

配置後は `Actions` で `Extra ...` を選び、まず `Run workflow` で試してください。組織の Action 許可リストの確認は講師が行います。

| サンプル | 変更する場所 | 権限 | 期待結果 |
| --- | --- | --- | --- |
| [manual-task.yml](manual-task.yml) | `inputs.target` の選択肢と shell の許可リスト | contents: read | 選んだフォルダーの一覧が出る |
| [daily-check.yml](daily-check.yml) | `cron` の日時 | contents: read | JST の時刻と変更有無が出る。PR は作らない |
| [build-report.yml](build-report.yml) | `find` の対象、保存日数 | contents: read | 次の job に一覧を渡し、Summary と artifact で確認できる |
| [notify-by-issue.yml](notify-by-issue.yml) | タイトルと本文 | notify job だけ issues: write | 実行ごとに確認依頼 Issue が1件できる |

## 定期実行を読む

このサンプルはタイムゾーン指定を省略し、UTC の `17 0 * * 1-5` を使っています。月〜金の JST 09:17 に相当します。祝日は除外しません。毎時0分の混雑を少し避ける例であり、**時刻どおりの開始を保証しません**。

| 想定時刻（JST） | UTC の cron |
| --- | --- |
| 毎日09:00 | `0 0 * * *` |
| 毎日18:30 | `30 9 * * *` |
| 月〜金09:17 | `17 0 * * 1-5` |

定期実行は既定ブランチに置いたものが対象です。配置・マージした時点から自動実行の対象になるため、当日は構文を見るだけにします。試用後は `Actions` → `Extra Daily Check` → メニュー → `Disable workflow` で停止するか、YAML を削除する PR をマージします。

## 入力と artifact の注意

入力は `${{ inputs.target }}` を `run` に直書きせず、`env` へ渡して引用符付きの `"$TARGET"` で読みます。CLI から想定外の値を渡されても shell 側の許可リストで拒否します。

job は別のマシンで動くので、ファイルはそのまま共有されません。artifact を upload → download して受け渡します。この例の保存期間は1日です。ログや artifact に秘密情報を入れないでください。

Issue 通知は意図的に単純な例です。再実行のたびに1件増えます。作成後は人が内容を確認して閉じます。基礎編の候補 PR の重複防止とは動作が異なります。

公式の根拠は [docs/references.md](../docs/references.md) にまとめています。
