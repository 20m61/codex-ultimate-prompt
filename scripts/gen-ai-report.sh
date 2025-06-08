#!/bin/bash
echo "## Claude/Copilot Activity Report (`date +%Y-%m-%d`)" > docs/metrics/ai-report.md
cat docs/metrics/ai-review-metrics.md >> docs/metrics/ai-report.md
tail -n 10 docs/task-log.md >> docs/metrics/ai-report.md
