#!/bin/bash
# Run any OpenClaw skill via Claude CLI with --add-dir
# Usage: run-skill.sh <skill-name> "<prompt>"
# Example: run-skill.sh infographic-dialog "生成关于 Docker 的信息图"
#          run-skill.sh liang "写一篇关于AI替代程序员的老梁风格文章"
#          run-skill.sh jp-tech-writing "Write about how DNS works"

SKILL_DIR="$HOME/.openclaw/workspace/skills"
SKILL_NAME="$1"
PROMPT="$2"
MODEL="${3:-sonnet}"

if [ -z "$SKILL_NAME" ] || [ -z "$PROMPT" ]; then
  echo "Usage: run-skill.sh <skill-name> \"<prompt>\" [model]"
  echo ""
  echo "Available skills:"
  ls "$SKILL_DIR"
  exit 1
fi

if [ ! -d "$SKILL_DIR/$SKILL_NAME" ]; then
  echo "Error: Skill '$SKILL_NAME' not found in $SKILL_DIR"
  exit 1
fi

echo "🚀 Running skill: $SKILL_NAME (model: $MODEL)"
echo "📝 Prompt: $PROMPT"
echo "---"

claude --add-dir "$SKILL_DIR/$SKILL_NAME" \
  --dangerously-skip-permissions \
  --model "$MODEL" \
  -p "Read SKILL.md in $SKILL_DIR/$SKILL_NAME and follow its instructions strictly.

Task: $PROMPT

When completely finished, run this command to notify:
openclaw system event --text \"Done: $SKILL_NAME completed\" --mode now"
