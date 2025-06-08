# タスク: AI自律開発ループ環境の完全構築（最終版）

## 🎯 目的
Claude・Copilot Agent・Codex が連携して、継続的なタスク生成、PRレビュー、フィードバック蓄積、評価指標出力、CI/CD対応までを自律的にループさせる環境を完全構築します。

---

## 🧰 実行内容

### 1. セーフインストール対応（上書き防止）
- 既存の `.github/`, `docs/`, `feedback/`, `scripts/` ディレクトリがある場合、上書き前に `.bak` 拡張子付きでバックアップ
- ファイルが未変更の場合はスキップ

### 2. ファイル展開
以下のファイル群を展開してください（内容は別途zip参照）：

- `docs/codex-usage-guide.md`
- `docs/task-log.md`
- `docs/metrics/ai-review-metrics.md`
- `.github/workflows/ci.yml`
- `scripts/gen-ai-report.sh`
- `feedback/claude-tasks/_template.md`

### 3. GitHub Actions の登録
- `ci.yml` の構文をチェック後、CIとして有効化
- `scripts/gen-ai-report.sh` を `schedule` トリガーで週次実行設定（毎週月曜 03:00 JST）

### 4. Claude連携強化
- Claudeに提案テンプレ `_template.md` を読み込ませ、提案時には：
  - 対象ファイルパス
  - 該当行範囲
  - 提案本文（カテゴリ＋重要度付き）
  を出力させるよう設計

### 5. task-logの運用強化
- `docs/task-log.md` は最大50件まで
- 超過時は `docs/logs/task-log-YYYYMMDD.md` に自動アーカイブ

---

## 🔐 セキュリティ/保護
- `.github/settings.yml` により `main` ブランチの保護ルール適用
  - CI成功必須
  - PRレビュー1件以上
  - 管理者にも適用

---

## ✅ 成果物
- 自動生成されたドキュメント、CI/CD構成、評価メトリクス
- CodexがClaudeとCopilot Agentからの提案をタスク化し、PRベースで改善
- `task-log.md` や `ai-review-metrics.md` に記録が蓄積され続けるループ環境

---

## 🚀 実行指示
上記内容をすべて自動で反映してください。処理ログは `task-log.md` に出力してください。
