# 講師向け: 準備・運営・検証

[受講者 README に戻る](../README.md)

## 1. 開催前に決めること

| 項目 | 設定値 |
| --- | --- |
| 開催日時・Teams URL | FIXME: 講師が記入 |
| 演習 organization | FIXME: 組織所有、公開範囲は組織規程に従う |
| 参加者別 repository | FIXME: 1人1リポジトリを推奨 |
| guideline-owners に相当するチーム | FIXME: 実在する可視チーム、対象 repo に write 以上 |
| platform-admins に相当するチーム | FIXME: 実在する可視チーム、対象 repo に write 以上 |
| レビュー担当者と参加者の対応表 | FIXME: 作成者以外の承認者を割り当てる |
| Advanced 実施可否・利用予算 | FIXME: 組織管理者に確認 |
| 見学用の実 run URL・Issue URL | FIXME: 講師の事前実行後に記入 |

未設定のチーム名でレビュー要求は動きません。参加者をチームに入れても、**自分が作った PR の承認者にはできません**。講師補助または相互レビュー担当を用意します。

## 2. 配布用リポジトリを準備する

1. 組織内に空の演習用リポジトリを準備します。GitHub 上の作成・公開は管理者が行い、この資料集全体を公開しないでください。
2. このサンプルフォルダーの**中身だけ**をそのリポジトリのルートへ配置します。`.github`、`.gitattributes`、`.gitignore`、取込済みハッシュも含めます。入れ子のフォルダーにしないでください。
3. [.github/CODEOWNERS](../.github/CODEOWNERS) の `@FIXME-org/...` を実チームに置き換えます。演習用に同じチームを両方の担当にしても構いません。
4. 初期ファイルを既定ブランチ `main` に配置した後、次節の ruleset を有効にします。以降の変更は PR 経由に統一します。
5. この構成をテンプレートとして参加者別リポジトリへ配布します。テンプレートのコピーだけでは ruleset・権限・設定が揃うとは限りません。**各リポジトリで**設定を確認します。
6. 参加者へ URL、レビュー担当者、README の場所を伝えます。基礎編の参加者には Git・GitHub CLI のインストールを要求しません。

初期状態では `.github/workflows/` に基礎4本と Advanced の source / lock があり、すべて手動実行から開始できます。`02 Check Guidelines` だけは対象ファイルの push / PR でも動きます。定期実行は `examples/` にあり、有効ではありません。

## 3. GitHub の設定

- [ ] Actions が有効である。通常 Actions はこのサンプルでは GitHub.com の GitHub-hosted Ubuntu runner を使う。
- [ ] Actions permissions で使用する Action を許可した。Advanced は lock 冒頭の `Custom actions used` とコンテナー一覧も確認した。
- [ ] `Allow GitHub Actions to create and approve pull requests` を有効化した。上位の組織・Enterprise ポリシーで禁止されていない。設定名に approve とあるが、サンプルは自動承認しない。
- [ ] `main` 対象の有効な ruleset で PR 必須・承認1名以上・コードオーナーレビュー必須・force push 禁止・削除禁止を設定した。参加者や bot にバイパスを与えていない。
- [ ] repo のプランと公開範囲が、必要な ruleset / CODEOWNERS の機能に対応している。使えない場合は開催前に環境を変更する。
- [ ] CODEOWNERS のエラー表示がなく、両チームに対象 repo の write 権限がある。チームは可視であり、指定した担当者が所属している。
- [ ] 参加者が write 権限を持つ。`Settings` が見えることを権限の判定方法にはしない。
- [ ] **この演習では path filter のある見出し検査を、すべての PR の必須 status check にしない。** 更新文書だけの PR では検査が起動せず、必須にすると Pending のまま詰まる。レビュー必須は維持し、動いた検査は人が確認する。
- [ ] PR 作成用 `proposal/` ブランチは作成可能である。全ブランチへの作成制限・署名必須などがある場合は講師が事前に対応方針を確認する。

`GITHUB_TOKEN` で作成した PR の `pull_request` 検査には、`Approve workflows to run` の承認が必要になる場合があります。write 権限のある担当者が差分を確認して実行を許可します。PAT を追加して迂回することは、この教材では行いません。仕様は [公式のイベント制限](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow#triggering-a-workflow-from-a-workflow) を確認してください。

## 4. 配布前のローカル検証

講師の Linux / WSL / Bash 環境で、**まだ演習の追記をしていないサンプル**を検証します。Git、Bash、GNU coreutils、GitHub CLI、actionlint、ShellCheck を使用します。参加者の環境には不要です。

サンプルのルートで実行します。

```bash
bash tests/test-samples.sh
bash tests/test-proposal.sh
shellcheck scripts/*.sh tests/*.sh
actionlint .github/workflows/hello-actions.yml \
  .github/workflows/check-guidelines.yml \
  .github/workflows/detect-source-change.yml \
  .github/workflows/propose-guideline-update.yml examples/*.yml
bash tests/validate-advanced.sh
```

最初のテストは初期ハッシュ一致を確認します。追記後の演習リポジトリで失敗するのは想定どおりです。PR のテストは一時ディレクトリ内の bare Git リポジトリと模擬 `gh` を使い、GitHub に通信・書き込みしません。

Advanced の検証だけは、Action やコンテナー参照の解決にネットワークが必要です。**AI は実行せず、課金 API の呼び出し・Issue 作成・push は行いません。** 検証スクリプトは一時 Git ルートで compile し、配布 lock と一致することを確認します。`gh-aw v0.86.2` を使用します。異なる版で lock が変わった場合は、無理に成功扱いせず差分をレビューしてください。

## 5. GitHub 上での事前リハーサル

実際の組織ポリシーと runner の動作はローカル検査では分かりません。開催3営業日前までに**講師用の別コピー**で確認します。PR / Issue を作成し、Advanced では AI 利用料が発生し得るため、予算の承認後に行います。

- [ ] Hello が成功する。
- [ ] 初期状態で `03 Detect Source Change` が「変更なし」になる。
- [ ] 初期状態で `04 Propose Guideline Update` の `propose` が skip する。
- [ ] README の変更だけでは `02 Check Guidelines` が起動しない。ガイドライン変更なら起動する。
- [ ] 保護ルールを有効にしたまま、ブラウザーで変更ブランチ→PR→他者承認→マージができる。
- [ ] 模擬更新を追記してマージすると「変更あり」になる。
- [ ] 候補 PR が1件作成され、CODEOWNERS のチームにレビュー要求が出る。
- [ ] 再実行しても PR が増えず、既存 PR のリンクが表示される。
- [ ] PR 本文から検知時点の文書と生成元 run を開ける。
- [ ] 検査の実行承認が表示される場合の操作を確認した。
- [ ] 承認後も自動マージされず、main のハッシュが古いままである。
- [ ] Advanced の前提を [docs/advanced.md](advanced.md) で確認し、実 run と Issue を準備した。
- [ ] 入力用 PR のレビュー待ちを含め、基礎の操作40分に収まる。レビュー担当者が常時対応できる。

不合格の項目があれば、参加者へ配布する前に解消します。受講者用リポジトリにはリハーサルの追記・候補 PR を残さず、初期コピーを配布してください。

## 6. 当日の運営

導入で「業務文書は貼らない」「前半の入力用 PR は人がマージ」「最後の bot PR は当日マージしない」を伝えます。Step 2 / 3 の PR は短い練習変更なので、担当レビュー者がすぐ処理できるようチャットで連絡します。

遅れた場合は Step 2 を講師デモに圧縮します。Step 3 の「変更なし→あり」、Step 4 / 5 の「候補→人の判断」は残します。Advanced が利用できなければ、実際の講師 run のログと生成 Issue を画面共有します。**架空の出力を成功実績として示さないでください。**

## 7. 初期化と終了後

最も簡単な再演習方法は、未変更のテンプレートから新しい参加者用コピーを作ることです。既存の記録を削除したり、ハッシュだけを現在値へ書き換えて「取込済み」に見せたりしないでください。

継続利用で候補 PR を実際にマージする場合は、内容を適切な改定文に直し、根拠と基準ハッシュの更新を人が承認します。**このサンプルの確認待ち文をそのまま業務に適用しないでください。** 入力が PR 作成後に更新されていれば、次の検知も「変更あり」になります。

任意の定期実行を有効にした場合は終了後に無効化します。ログと artifact の保存期間、予算、リポジトリの維持・削除方針を組織側で決めます。1回の上限は月額予算の代わりではありません。
