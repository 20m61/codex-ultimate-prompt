# 🎯 タスク: AI 自律開発ループ環境の完全構築目的

Claude・Copilot Agent・Codex が連携して、継続的なタスク生成、PR レビュー、フィードバック蓄積、評価指標出力、CI/CD 対応までを自律的にループさせる環境を完全構築します。

## 📦 含まれる内容

- GitHub Actions ワークフロー
- Claude との改善提案テンプレート
- Codex が処理するスクリプト一式
- `task-log` 管理・評価メトリクス

---

## 🧰 実行内容

### 1. セーフインストール対応（上書き防止）

- 既存の `.github/`, `docs/`, `feedback/`, `scripts/` ディレクトリがある場合、上書き前に `.bak` 拡張子付きでバックアップ
- ファイルが未変更の場合はスキップ

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
    - cron: '0 18 * * 0' # 毎週月曜3:00 JST (UTC 09:00)

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
if [ ! -f "$LOG_FILE" ]; then
  echo "# ✅ AIタスク実行ログ" > "$LOG_FILE"
  echo "| 日時 | タスク内容 | ステータス |" >> "$LOG_FILE"
  echo "|------|------------|------------|" >> "$LOG_FILE"
fi
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

template_file = feedback_dir / "_template.md"

def parse_feedback_file(file):
    with file.open() as f:
        content = f.read()
    lines = content.splitlines()
    if len(lines) < 6 or lines[0].strip() == "## 🧠 改善提案テンプレート":
        return None
    try:
        task = {
            "file": lines[1].split(':', 1)[1].strip(),
            "range": lines[2].split(':', 1)[1].strip(),
            "type": lines[3].split(':', 1)[1].strip(),
            "importance": lines[4].split(':', 1)[1].strip(),
            "body": lines[5].split(':', 1)[1].strip(),
        }
        return task
    except Exception as e:
        print(f"[WARN] {file}: parse error: {e}")
        return None

for file in feedback_dir.glob("*.md"):
    if file == template_file:
        continue
    task = parse_feedback_file(file)
    if task:
        out_path = tasks_dir / (file.stem + ".json")
        with out_path.open("w") as f:
            json.dump(task, f, indent=2)
    else:
        print(f"[SKIP] {file}")
```

#### 📄 `feedback/claude-tasks/_template.md`

```markdown
## 🧠 改善提案テンプレート

- 対象ファイル: `パス/ファイル名`
- 範囲: 対象行（例: 45-60 行）
- 種別:
  - [ ] 構文改善
  - [ ] 意味明確化
  - [ ] 表現変更
  - [ ] セキュリティ
- 重要度:
  - [ ] ★★★★★
  - [ ] ★★★★☆
  - [ ] ★★★☆☆
  - [ ] ★★☆☆☆
  - [ ] ★☆☆☆☆
- 内容: ここに具体的な提案を記入します。

---

### 記入例

- 対象ファイル: `scripts/parse-claude-feedback.py`
- 範囲: 10-20 行
- 種別: [x] 構文改善
- 重要度: [x] ★★★★☆
- 内容: 例外処理を追加し、不正なフォーマットのファイルをスキップするようにしてください。
```

#### 📄 `docs/task-log.md`

```markdown
# ✅ AI タスク実行ログ

| 日時       | タスク内容         | ステータス |
| ---------- | ------------------ | ---------- |
| 2025-06-08 | Codex 環境初期構築 | ✅ 完了    |
```

#### 📄 `docs/metrics/ai-review-metrics.md`

```markdown
# 📊 AI 開発レビュー評価指標

| 日付       | 評価者 | 修正内容          | 精度 | 実用性 | 一貫性 |
| ---------- | ------ | ----------------- | ---- | ------ | ------ |
| 2025-06-08 | Claude | task-log 分割提案 | 5.0  | 4.5    | 4.8    |
```

#### 📄 `docs/reports/ai-report-2025-06-08.md`

```markdown
# AI Review Report (2025-06-08)

- TODO: Append task-log summaries
```

#### 📄 install.sh

```bash
#!/bin/bash
# セーフインストール: 既存ディレクトリを .bak でバックアップし、ファイル展開を自動化
set -e

for dir in .github docs feedback scripts; do
  if [ -d "$dir" ]; then
    bak_dir="${dir}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dir" "$bak_dir"
    echo "Backup: $dir -> $bak_dir"
  fi
  mkdir -p "$dir"
done

echo "展開処理はここに追加してください（例: ファイルコピーやテンプレート展開）"
```
