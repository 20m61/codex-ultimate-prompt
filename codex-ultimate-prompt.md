# タスク: AI自律開発ループ環境の完全構築

## 🎯 目的
Claude・Copilot Agent・Codex が連携して、継続的なタスク生成、PRレビュー、フィードバック蓄積、評価指標出力、CI/CD対応までを自律的にループさせる環境を完全構築します。

---

## 🧰 実行内容

### 1. セーフインストール対応（上書き防止）
- 既存の `.github/`, `docs/`, `feedback/`, `scripts/` ディレクトリがある場合、上書き前に `.bak` 拡張子付きでバックアップ
- ファイルが未変更の場合はスキップ

### 2. ファイル展開
以下のファイル群を展開してください（内容は[Codex 実行用プロンプト & ファイルバンドル](#-codex-%E5%AE%9F%E8%A1%8C%E7%94%A8%E3%83%97%E3%83%AD%E3%83%B3%E3%83%97%E3%83%88--%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%83%90%E3%83%B3%E3%83%89%E3%83%AB)）：

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

# 🧠 Codex 実行用プロンプト & ファイルバンドル

以下の構成ファイルをこのプロジェクトに追加・適用してください。すべてのファイルはコードブロックとして含まれています。  
既存ファイルが存在する場合は `.bak` をつけてバックアップしてから書き換えてください。

## 📄 .github/workflows/ci.yml

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 18 * * 0'  # 毎週月曜3:00 JST

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        language: [node, python, php]
    steps:
      - uses: actions/checkout@v3
      - name: Set up ${{ matrix.language }}
        uses: actions/setup-${{ matrix.language }}@v3
        continue-on-error: true
      - run: echo "Run Lint/Test for ${{ matrix.language }}"
```

## 📄 scripts/gen-ai-report.sh

```bash
#!/bin/bash
echo "Generating AI review report..."
DATE=$(date +%Y-%m-%d)
mkdir -p docs/reports
echo "# AI Review Report (${DATE})" > docs/reports/ai-report-${DATE}.md
echo "- TODO: Append task-log summaries" >> docs/reports/ai-report-${DATE}.md
```

## 📄 docs/task-log.md

```markdown
# ✅ AIタスク実行ログ

| 日時 | タスク内容 | ステータス |
|------|------------|------------|
| 2025-06-09 | Codex 環境初期構築 | ✅ 完了 |
```

## 📄 docs/metrics/ai-review-metrics.md

```markdown
# 📊 AI開発レビュー評価指標

| 日付 | 評価者 | 修正内容 | 精度 | 実用性 | 一貫性 |
|------|--------|----------|------|--------|--------|
| 2025-06-09 | Claude | task-log 分割提案 | 5.0 | 4.5 | 4.8 |
```

## 📄 feedback/claude-tasks/_template.md

```markdown
## 🧠 改善提案テンプレート

- 対象ファイル: `パス/ファイル名`
- 範囲: 対象行（例: 45-60行）
- 種別: （構文改善 / 意味明確化 / 表現変更 / セキュリティ）
- 重要度: ★★★☆☆
- 内容: ここに具体的な提案を記入します。
```

## 📄 docs/codex-usage-guide.md

```markdown
# Codex実行ガイド

## スタート方法
1. この `.md` ファイルを Web UI に貼り付け
2. Codex が内容を読み取り、ファイルを生成
3. `task-log.md` に履歴を自動記録

## 注意点
- 既存ファイルは `.bak` でバックアップ保存
- スクリプト実行には `chmod +x scripts/gen-ai-report.sh` を忘れずに
```

---

## 🚀 実行指示
上記内容をすべて自動で反映してください。処理ログは `task-log.md` に出力してください。
