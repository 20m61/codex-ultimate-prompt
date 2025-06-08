# 🎯 タスク: AI自律開発ループ環境の完全構築目的

Claude・Copilot Agent・Codex が連携して、継続的なタスク生成、PRレビュー、フィードバック蓄積、評価指標出力、CI/CD対応までを自律的にループさせる環境を完全構築します。

## 📦 含まれる内容

* GitHub Actions ワークフロー
* Claude との改善提案テンプレート
* Codex が処理するスクリプト一式
* `task-log` 管理・評価メトリクス

---

## 🧰 実行内容

### 1. セーフインストール対応（上書き防止）

* 既存の `.github/`, `docs/`, `feedback/`, `scripts/` ディレクトリがある場合、上書き前に `.bak` 拡張子付きでバックアップ
* ファイルが未変更の場合はスキップ

### 2. ファイル展開（コードブロック付きで記述）

#### 📄 `.github/workflows/ci.yml`

```yaml
name: CI

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
    steps:
      - uses: actions/checkout@v3
      - name: Run archive task log script
        run: |
          chmod +x scripts/archive-task-log.sh
          ./scripts/archive-task-log.sh

  parse_claude_feedback:
    runs-on: ubuntu-latest
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
```

#### 📄 `scripts/gen-ai-report.sh`

```bash
#!/bin/bash
echo "Generating AI review report..."
DATE=$(date +%Y-%m-%d)
mkdir -p docs/reports
echo "# AI Review Report (${DATE})" > docs/reports/ai-report-${DATE}.md
echo "- TODO: Append task-log summaries" >> docs/reports/ai-report-${DATE}.md
```

#### 📄 `scripts/archive-task-log.sh`

```bash
#!/bin/bash
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
```

#### 📄 `scripts/parse-claude-feedback.py`

```python
#!/usr/bin/env python3
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
```

#### 📄 `feedback/claude-tasks/_template.md`

```markdown
## 🧠 改善提案テンプレート

- 対象ファイル: `パス/ファイル名`
- 範囲: 対象行（例: 45-60行）
- 種別: （構文改善 / 意味明確化 / 表現変更 / セキュリティ）
- 重要度: ★★★☆☆
- 内容: ここに具体的な提案を記入します。
```

#### 📄 `docs/task-log.md`

```markdown
# ✅ AIタスク実行ログ

| 日時 | タスク内容 | ステータス |
|------|------------|------------|
| 2025-06-09 | Codex 環境初期構築 | ✅ 完了 |
```

#### 📄 `docs/metrics/ai-review-metrics.md`

```markdown
# 📊 AI開発レビュー評価指標

| 日付 | 評価者 | 修正内容 | 精度 | 実用性 | 一貫性 |
|------|--------|----------|------|--------|--------|
| 2025-06-09 | Claude | task-log 分割提案 | 5.0 | 4.5 | 4.8 |
```

#### 📄 `docs/codex-usage-guide.md`

````markdown
# Codex実行ガイド

## スタート方法
1. この `.md` ファイルを Web UI に貼り付け
2. Codex が内容を読み取り、ファイルを生成
3. `task-log.md` に履歴を自動記録

## 注意点
- 既存ファイルは `.bak` でバックアップ保存
- スクリプト実行には `chmod +x scripts/gen-ai-report.sh` を忘れずに

## GitHub ブランチ保護ルールの設定方法

`main` ブランチに以下の保護ルールを適用するには、**ユーザーが以下のコマンドをローカルで実行する必要があります**。

```bash
# REPLACE: 以下の OWNER/REPO をご自身の GitHub に置き換えてください
gh api repos/OWNER/REPO/branches/main/protection \
  --method PUT \
  --field required_status_checks.strict=true \
  --field enforce_admins=true \
  --field required_pull_request_reviews.dismiss_stale_reviews=true \
  --field required_pull_request_reviews.required_approving_review_count=1 \
  --field restrictions=null
```
