タスク: AI自律開発ループ環境の完全構築🎯 目的Claude・Copilot Agent・Codex が連携して、継続的なタスク生成、PRレビュー、フィードバック蓄積、評価指標出力、CI/CD対応までを自律的にループさせる環境を完全構築します。📦 含まれる内容：GitHub Actions ワークフローClaude との改善提案テンプレートCodex が処理するスクリプト一式task-log 管理・評価メトリクス🧰 実行内容1. セーフインストール対応（上書き防止）既存の .github/, docs/, feedback/, scripts/ ディレクトリがある場合、上書き前に .bak 拡張子付きでバックアップファイルが未変更の場合はスキップ2. ファイル展開以下のファイル群を展開してください（内容はCodex 実行用プロンプト & ファイルバンドル）：docs/codex-usage-guide.mddocs/task-log.mddocs/metrics/ai-review-metrics.md.github/workflows/ci.ymlscripts/gen-ai-report.shscripts/archive-task-log.shscripts/parse-claude-feedback.pyfeedback/claude-tasks/_template.md3. GitHub Actions の登録ci.yml の構文をチェック後、CIとして有効化scripts/gen-ai-report.sh を schedule トリガーで週次実行設定（毎週月曜 03:00 JST）scripts/archive-task-log.sh を schedule トリガーで毎日実行設定（毎日 00:00 JST）scripts/parse-claude-feedback.py を feedback/claude-tasks ディレクトリへの push トリガーで実行設定4. Claude連携強化Claudeに提案テンプレ _template.md を読み込ませ、提案時には：対象ファイルパス該当行範囲提案本文（カテゴリ＋重要度付き）を出力させるよう設計scripts/parse-claude-feedback.py を使用して、Claudeからのフィードバック（feedback/claude-tasks 配下にプッシュされたもの）をタスクとして自動的に解析・構造化5. task-logの運用強化docs/task-log.md は最大50件まで超過時は docs/logs/task-log-YYYYMMDD.md に自動アーカイブ🔐 セキュリティ/保護main ブランチの保護ルールは、ユーザーが手動で docs/codex-usage-guide.md に記載された gh api コマンドを実行することで適用されます。このルールには以下が含まれます。CI成功必須PRレビュー1件以上管理者にも適用✅ 成果物自動生成されたドキュメント、CI/CD構成、評価メトリクスCodexがClaudeとCopilot Agentからの提案をタスク化し、PRベースで改善task-log.md や ai-review-metrics.md に記録が蓄積され続けるループ環境🧠 Codex 実行用プロンプト & ファイルバンドル以下の構成ファイルをこのプロジェクトに追加・適用してください。すべてのファイルはコードブロックとして含まれています。既存ファイルが存在する場合は .bak をつけてバックアップしてから書き換えてください。📄 .github/workflows/ci.ymlname: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 18 * * 0'  # 毎週月曜3:00 JST (UTC 09:00)

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

  archive_task_log:
    runs-on: ubuntu-latest
    # 毎日 00:00 JST に実行 (UTC 15:00)
    schedule:
      - cron: '0 15 * * *'
    steps:
      - uses: actions/checkout@v3
      - name: Run archive task log script
        run: |
          chmod +x scripts/archive-task-log.sh
          ./scripts/archive-task-log.sh

  parse_claude_feedback:
    runs-on: ubuntu-latest
    # feedback/claude-tasks ディレクトリへのプッシュ時に実行
    # NOTE: 通常はPRマージイベントなどでトリガーする方が適切ですが、
    # このプロンプトの簡潔さのためpushイベントに設定しています。
    if: github.event_name == 'push' && contains(github.event.head_commit.modified, 'feedback/claude-tasks/')
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.x'
      - name: Run parse Claude feedback script
        run: |
          chmod +x scripts/parse-claude-feedback.py
          python3 scripts/parse-claude-feedback.py
📄 scripts/gen-ai-report.sh#!/bin/bash
echo "Generating AI review report..."
DATE=$(date +%Y-%m-%d)
mkdir -p docs/reports
echo "# AI Review Report (${DATE})" > docs/reports/ai-report-${DATE}.md
echo "- TODO: Append task-log summaries" >> docs/reports/ai-report-${DATE}.md
📄 docs/task-log.md# ✅ AIタスク実行ログ

| 日時 | タスク内容 | ステータス |
|------|------------|------------|
| 2025-06-09 | Codex 環境初期構築 | ✅ 完了 |
📄 docs/metrics/ai-review-metrics.md# 📊 AI開発レビュー評価指標

| 日付 | 評価者 | 修正内容 | 精度 | 実用性 | 一貫性 |
|------|--------|----------|------|--------|--------|
| 2025-06-09 | Claude | task-log 分割提案 | 5.0 | 4.5 | 4.8 |
📄 feedback/claude-tasks/_template.md## 🧠 改善提案テンプレート

- 対象ファイル: `パス/ファイル名`
- 範囲: 対象行（例: 45-60行）
- 種別: （構文改善 / 意味明確化 / 表現変更 / セキュリティ）
- 重要度: ★★★☆☆
- 内容: ここに具体的な提案を記入します。
📄 docs/codex-usage-guide.md# Codex実行ガイド

## スタート方法
1. この `.md` ファイルを Web UI に貼り付け
2. Codex が内容を読み取り、ファイルを生成
3. `task-log.md` に履歴を自動記録

## 注意点
- 既存ファイルは `.bak` でバックアップ保存
- スクリプト実行には `chmod +x scripts/gen-ai-report.sh` を忘れずに

## GitHub ブランチ保護ルールの設定方法

`main` ブランチに以下の保護ルールを適用するには、**ユーザーが以下のコマンドをローカルで実行する必要があります**。`OWNER/REPO` の部分を自身のGitHubリポジトリ情報に置き換えてください。

```bash
# REPLACE: 以下の OWNER/REPO をご自身の GitHub に置き換えてください
gh api repos/OWNER/REPO/branches/main/protection \
  --method PUT \
  --field required_status_checks.strict=true \
  --field enforce_admins=true \
  --field required_pull_request_reviews.dismiss_stale_reviews=true \
  --field required_pull_request_reviews.required_approving_review_count=1 \
  --field restrictions=null
📄 scripts/archive-task-log.sh#!/bin/bash
LOG_FILE="docs/task-log.md"
COUNT=$(grep -c '^|' "$LOG_FILE")

if [ "$COUNT" -gt 50 ]; then
  DATE=$(date +%Y%m%d)
  mkdir -p docs/logs
  mv "$LOG_FILE" "docs/logs/task-log-$DATE.md"
  echo "# ✅ AIタスク実行ログ" > "$LOG_FILE"
  echo "| 日時 | タスク内容 | ステータス |" >> "$LOG_FILE"
  echo "|------|------------|------------|" >> "$LOG_FILE"
fi
📄 scripts/parse-claude-feedback.py#!/usr/bin/env python3
import os, json
from pathlib import Path

feedback_dir = Path("feedback/claude-tasks")
tasks_dir = Path("tasks")
tasks_dir.mkdir(exist_ok=True)

for file in feedback_dir.glob("*.md"):
    with file.open() as f:
        content = f.read()

    lines = content.splitlines()
    task = {
        "file": lines[1].split(':', 1)[1].strip(),
        "range": lines[2].split(':', 1)[1].strip(),
        "type": lines[3].split(':', 1)[1].strip(),
        "importance": lines[4].split(':', 1)[1].strip(),
        "body": lines[5].split(':', 1)[1].strip(),
    }

    out_path = tasks_dir / (file.stem + ".json")
    with out_path.open("w") as f:
        json.dump(task, f, indent=2)
