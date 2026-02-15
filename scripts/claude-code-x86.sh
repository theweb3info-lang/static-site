#!/bin/bash
# Claude Code on x86 Mac via Docker
# Usage: bash claude-code-x86.sh

set -e

# Check Docker
if ! command -v docker &>/dev/null; then
  echo "❌ Docker not found. Install Docker Desktop first:"
  echo "   https://www.docker.com/products/docker-desktop/"
  exit 1
fi

echo "🚀 Starting Claude Code in Docker..."

# Run with persistent config
docker run -it --rm \
  -v "$HOME/.claude-code:/root/.claude" \
  -v "$(pwd):/workspace" \
  -w /workspace \
  -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" \
  --name claude-code \
  node:22-slim bash -c '
    echo "📦 Installing Claude Code..."
    npm i -g @anthropic-ai/claude-code 2>/dev/null
    echo "✅ Ready!"
    claude
  '
