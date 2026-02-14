# WeChat Article Style Generator

Convert markdown articles to beautifully styled HTML with WeChat official account aesthetics.

## Quick Start

```bash
cd ~/.openclaw/workspace/skills/wechat-article
./wechat-style.sh
```

Then enter:
1. Article title
2. Paste markdown content (Ctrl+D when done)

## From File

```bash
./wechat-style.sh --title "文章标题" --input article.md
```

## Output

Generated HTML files go to:
```
~/.openclaw/workspace/static-site/{filename}.html
```

Preview URL:
```
https://theweb3info-lang.github.io/static-site/{filename}.html
```

## Features

✨ WeChat official account styling  
📱 Mobile-first responsive design  
🎨 Highlighted key points (yellow marker)  
📊 Data cards and quote blocks  
🖼️ Auto-integrated Unsplash images  
🚀 Auto-commit and push to GitHub Pages

## Examples

**Example 1:** Interactive mode
```bash
./wechat-style.sh
```

**Example 2:** From markdown file
```bash
./wechat-style.sh \\
  --title "AI 效率悖论" \\
  --input blog-post.md \\
  --cover "https://images.unsplash.com/photo-xxx"
```

**Example 3:** Quick generation
```bash
./wechat-style.sh --title "标题" --content "$(cat article.md)"
```

## Markdown Support

- `## Heading` → Green-bordered section header
- `**Bold**` → Strong emphasis
- `==Highlight==` → Yellow marker background
- `> Quote` → Grey box with green border
- `- List` → Green bullet points
- `![img](url)` → Responsive images
- `---` → Centered divider (━━━)

## Full Documentation

See [SKILL.md](./SKILL.md) for complete usage guide.

---

**Created:** 2026-02-11  
**Purpose:** Reusable WeChat article styling for content publishing
