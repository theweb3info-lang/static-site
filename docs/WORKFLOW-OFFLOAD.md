# Workflow Offload Strategy

To keep main session context lean and avoid hitting 200k token limit too fast.

## Task Routing Rules

### Main Session (ONLY for)
- Quick Q&A (1-2 turn conversations)
- Tool orchestration (message, cron, nodes)
- Heartbeats
- Session management

**Avoid:** Long content generation, multi-turn research, heavy analysis

### Sub-Agents (sessions_spawn)
Use for isolated heavy work that reports back:
```bash
sessions_spawn task="Write a technical article about X" model="anthropic/claude-opus-4-6"
```

**Good for:**
- Blog post writing
- Research reports
- Long-form content creation
- Multi-step analysis

### Claude CLI (claude -p "...")
Complex tasks that don't need OpenClaw tools:
```bash
claude -p "Research and summarize the top 5 AI trends in 2026"
```

**Good for:**
- Deep research (no tool integration needed)
- Complex coding projects
- Multi-file refactoring

### Qwen/Copilot (FREE)
Simple one-shot tasks:
```bash
qwen -p "Translate this to English: 你好世界"
copilot -p "Write a git commit message for: added token tracking"
```

**Good for:**
- Translations
- Summaries
- Simple formatting
- Quick code snippets

### Direct Skill Execution
No conversation needed:
```bash
cd ~/.openclaw/workspace/skills/wechat-article
./wechat-style.sh --title "Title" --input article.md
```

**Good for:**
- Image generation (all image skills)
- File conversion
- Template-based generation

## Example: Content Creation Workflow

**Bad (burns main session tokens):**
```
User: Write a blog post about AI OS
Agent: [writes 2000 words in main session]
→ Uses 30k input + 5k output = 35k tokens
```

**Good (offloads to sub-agent):**
```
User: Write a blog post about AI OS
Agent: sessions_spawn task="Write blog post about AI OS concept, 1500 words, technical but accessible" model="opus"
→ Isolated session does the work, reports back when done
→ Main session only uses ~2k tokens for orchestration
```

## When to Use Each

| Task Type | Route To | Why |
|-----------|----------|-----|
| "Send X to Telegram" | Main session | Needs message tool |
| "Write article about Y" | Sub-agent | Heavy content gen |
| "Research Z and report" | Claude CLI | Complex, no tools |
| "Translate this" | Qwen | Simple, free |
| "Generate image of W" | Skill direct | No conversation |
| "Check heartbeat tasks" | Main session | Needs cron/state |

## Token Budget Per Task Type

- **Main session turn:** Aim for <10k total (input+output)
- **Sub-agent spawn:** Can use 50-100k (separate quota)
- **CLI offload:** Uses external API (no main session burn)
