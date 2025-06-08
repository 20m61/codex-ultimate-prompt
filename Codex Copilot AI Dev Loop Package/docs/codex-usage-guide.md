# Codex 初回起動手順ガイド

## 1. 準備
- `000_bootstrap-ai-dev-loop-ultra.md` をプロジェクトルートに置く
- Codex Webで選択し「Start Task」で起動

## 2. 実行確認
- `.codex/`, `docs/`, `.github/`, `feedback/` が生成されている
- `docs/task-log.md` に実行記録がある

## 3. 問題が出たら
- `.feedback/ci-feedback.log` をチェック
- Claude提案が `feedback/claude-tasks/` に追加されているか確認
