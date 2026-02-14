---
name: jp-tech-writing
description: Write technical articles in Japanese-style (日系风格), inspired by books like "程序员的数学", "图解HTTP", "程序是怎样跑起来的". Use when writing tutorials, explanations, blog posts about technical concepts. Outputs bilingual (English + Chinese) markdown with ASCII diagrams, analogies, and progressive disclosure. Triggers on requests like "write a technical article", "explain X concept", "create a tutorial about Y", "日系风格写作", "技术博客".
---

# Japanese-Style Technical Writing (日系风格技术写作)

Write technical content that is clear, visual, and reader-friendly.

## Core Philosophy

> "让复杂的事情变得简单，让枯燥的事情变得有趣，让抽象的事情变得具体。"

## Quick Start

1. **Open with a scene or question** — not definitions
2. **Every concept needs an analogy** — from daily life
3. **Visualize with ASCII diagrams** — memory, flow, state
4. **Bilingual output** — English paragraph first, then Chinese
5. **Progressive difficulty** — never jump

## Article Structure

```
## Opening (场景/问题引入)
- Hook with relatable scenario
- State prerequisites and learning outcomes

## Part 1-N (渐进式章节)
- Question as section title
- Analogy → Diagram → Definition → Code
- Special boxes: 🎯常见误区 / 📖设计故事 / 🖼️一图胜千言

## Summary (总结)
- Visual recap diagram
- One-sentence takeaway
- Next steps + reflection question
```

## Opening Patterns

❌ **Wrong:** Start with terminology definitions
```
依赖注入（Dependency Injection）是一种实现控制反转的设计模式...
```

✅ **Right:** Start with a scene
```
想象你开了一家咖啡店。每天早上，你需要咖啡豆...
```

✅ **Right:** Start with a problem
```
你有没有遇到过这种情况？改了一行代码，要改十个文件...
```

## Bilingual Format

Always output English paragraph first, then Chinese:

```markdown
Here's something that might surprise you: **AI cannot read text.**

这可能会让你惊讶：**AI 根本不认识文字。**
```

## Special Sections

### 🎯 Explain Like I'm 5
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 如果让你向小朋友解释……
━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Simple analogy explanation]
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### ⚠️ Common Misconceptions
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ 常见误区
━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ **误区：** [wrong belief]
✅ **真相：** [correct explanation]
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 📖 Design Story
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 设计背后的故事
━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Historical context, why this design exists]
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## ASCII Diagram Types

### Flow Diagram
```
┌─────────┐    ①步骤    ┌─────────┐
│  Start  │ ──────────→ │  End    │
└─────────┘             └─────────┘
```

### Memory Layout
```
┌─────┬─────┬─────┬─────┐
│  A  │  B  │  C  │  D  │  ← 连续存储
└─────┴─────┴─────┴─────┘
```

### State Diagram
```
     ┌─────────┐
     │ Pending │
     └────┬────┘
          │ resolve()
          ▼
     ┌─────────┐
     │Fulfilled│
     └─────────┘
```

## Code Examples

Always follow this pattern:
1. "让我们试试..." (Let's try...)
2. Short code block (max 15 lines)
3. "发生了什么？" (What happened?)
4. Explanation

```markdown
Let's try a simple example:

让我们试一个简单的例子：

\`\`\`javascript
const x = 1;
console.log(x);
\`\`\`

What happened? The variable `x` stores the value 1...

发生了什么？变量 `x` 存储了值 1...
```

## Writing Checklist

Before finishing:
- [ ] Opens with scene/question, not definition?
- [ ] Every concept has an analogy?
- [ ] Has at least 2 ASCII diagrams?
- [ ] Code examples are ≤15 lines each?
- [ ] Bilingual format throughout?
- [ ] Ends with summary + next steps?

## Full Reference

For complete writing principles, examples, and templates:
→ See [references/writing-guide.md](references/writing-guide.md)
