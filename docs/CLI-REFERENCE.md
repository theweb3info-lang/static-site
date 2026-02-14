# CLI Reference

Detailed usage for external CLIs referenced in TOOLS.md.

## Claude CLI (Claude Code)
```bash
claude -p "prompt here"  # One-shot
claude                    # Interactive mode
```
- Model: Opus 4.6
- Use for: Complex multi-step work, research, coding
- Path: /opt/homebrew/bin/claude

## Copilot CLI
```bash
copilot -p "prompt here"  # One-shot
copilot                    # Interactive
```
- Cost: FREE (GitHub Pro)
- Use for: GitHub ops, quick code Q&A
- Path: /opt/homebrew/bin/copilot

## Qwen CLI
```bash
qwen -p "prompt here"      # One-shot
```
- Cost: FREE (Alibaba Cloud)
- Use for: Translations, summaries, simple tasks
- Path: /opt/homebrew/bin/qwen

## Codex CLI
```bash
codex -q "prompt here"     # Quiet one-shot
```
- Cost: OpenAI API credits
- Use for: Coding tasks, file edits
- Path: /opt/homebrew/bin/codex

## System Status Commands

### Memory (human-readable)
```bash
top -l 1 -s 0 | grep PhysMem
# Output: PhysMem: 21G used (2376M wired, 3676M compressor), 2148M unused.
```

### Uptime & Load
```bash
uptime
```

### Disk (macOS APFS - use Data volume)
```bash
df -h /System/Volumes/Data | tail -1
# Shows actual user data: 460Gi total, 105Gi used, 335Gi available
```
