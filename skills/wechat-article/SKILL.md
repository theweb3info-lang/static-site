# wechat-article - WeChat Official Account Style Article Generator

Convert markdown articles to beautifully styled HTML with WeChat official account aesthetics.

## When to Use This Skill

Use this skill when Andy asks to:
- "做成微信公众号格式"
- "美化这篇文章"
- "生成 HTML 版本"
- "发布到 static-site"
- Create styled article pages for web/WeChat

## Features

✨ **WeChat Official Account Styling**
- Clean, professional typography
- Mobile-first responsive design
- Highlighted key points (yellow marker effect)
- Emoji integration
- Data cards and quote blocks

🎨 **Visual Elements**
- Cover images (Unsplash integration)
- Section images
- Dividers (━━━ style)
- Color-coded headings (green accent)
- Data boxes with statistics

📱 **Responsive Design**
- Optimized for mobile (WeChat browser)
- Works on desktop too
- Max width 750px (WeChat standard)
- Touch-friendly spacing

## Usage

### Method 1: Interactive Script

```bash
cd ~/.openclaw/workspace/skills/wechat-article
./wechat-style.sh
```

Follow prompts:
1. Enter article title
2. Paste markdown content (Ctrl+D when done)
3. Optionally provide cover image URL
4. Script generates HTML and opens preview

### Method 2: From File

```bash
./wechat-style.sh --input article.md --title "标题" --output filename.html
```

### Method 3: Quick Generation

```bash
./wechat-style.sh --title "文章标题" --content "$(cat article.md)"
```

## Output

Generated files go to:
- `~/.openclaw/workspace/static-site/{filename}.html`
- Automatically committed and pushed to GitHub Pages
- Preview URL: `https://theweb3info-lang.github.io/static-site/{filename}.html`

## Markdown Conventions

The script recognizes these markdown patterns:

### Headings
```markdown
# H1 - Main title (centered, 24px)
## H2 - Section header (green left border)
### H3 - Subsection (18px bold)
```

### Text Formatting
```markdown
**Bold text** - Emphasis (black, 700 weight)
_Italic text_ - Converted to normal (WeChat style avoids italics)
`code` - Inline code (monospace)
```

### Lists
```markdown
- Bullet point (green • marker)
  - Nested item
1. Numbered list (auto-converted to bullets for cleaner look)
```

### Special Blocks

#### Highlighted Text
```markdown
==Highlighted text== or [[Highlighted text]]
```
Renders with yellow marker background effect.

#### Quote Blocks
```markdown
> This is a quote
> Multiple lines supported
```
Renders as grey box with green left border.

#### Data Boxes
```markdown
:::data
**数据标题**
• Data point 1
• Data point 2
:::
```
Renders as blue info box with border.

#### Section Intro
```markdown
:::intro
Introduction text that gets highlighted background
:::
```
Renders with yellow background.

### Images

```markdown
![alt text](image-url)
```

**Auto Image Sources:**
- If URL starts with `http` - uses as-is
- If URL is `cover` - uses Unsplash cover image
- If URL is `section-{topic}` - uses relevant Unsplash image
- Otherwise, searches Unsplash for the alt text

**Manual Image URLs:**
```markdown
![Cover](https://images.unsplash.com/photo-xxx?w=1200&q=80)
```

### Dividers

```markdown
---
***
━━━
```

All render as centered `━━━` divider.

### Emojis

Add inline: `📊 数据`, `💡 要点`, `🔥 热点`

Common ones auto-inserted:
- `## 💡 Section` for insight sections
- `## 📊 Data` for statistics
- `## 🔥 Key Point` for highlights

## Customization

### Colors

Edit `template.html` CSS variables:
```css
--primary-green: #07c160;  /* WeChat green */
--highlight-yellow: #fef3ac;
--text-dark: #3a3a3a;
--border-grey: #e5e5e5;
```

### Fonts

Defaults to WeChat standard stack:
```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
```

### Layout Width

Change max-width in template:
```css
.article {
    max-width: 750px; /* WeChat standard */
}
```

## Examples

### Example 1: Blog Post

```bash
./wechat-style.sh --title "AI 效率悖论" --input blog-post.md
```

Result: https://theweb3info-lang.github.io/static-site/ai-burnout.html

### Example 2: Technical Article

```bash
./wechat-style.sh \\
  --title "深度学习入门指南" \\
  --input deep-learning.md \\
  --cover "https://images.unsplash.com/photo-xxx"
```

### Example 3: From Clipboard

```bash
pbpaste | ./wechat-style.sh --title "剪贴板文章"
```

## Workflow Integration

Typical Andy workflow:
1. Andy writes article in markdown (or asks me to generate)
2. Andy says "做成 skill" or "生成 HTML"
3. I run: `cd skills/wechat-article && ./wechat-style.sh`
4. I provide preview URL
5. Andy checks on mobile
6. If good, I commit & push

## Template Structure

`template.html` contains:
- `{{TITLE}}` - Article title
- `{{CONTENT}}` - Processed HTML body
- `{{COVER_IMAGE}}` - Cover image URL (optional)
- `{{DESCRIPTION}}` - Meta description (auto-generated from first paragraph)

## Technical Notes

- Uses Python `markdown` library for conversion
- Pandoc fallback if Python unavailable
- Automatic Unsplash image integration
- Git auto-commit with descriptive messages
- Mobile viewport meta tag included
- No external dependencies in final HTML (all CSS inline)

## Maintenance

### Update Template
Edit `template.html` to change base styling.

### Add New Markdown Patterns
Edit `wechat-style.sh` processing section:
```bash
# Add custom pattern
content=$(echo "$content" | sed 's/pattern/replacement/g')
```

### Change Output Directory
Edit `OUTPUT_DIR` variable in script:
```bash
OUTPUT_DIR="$HOME/.openclaw/workspace/static-site"
```

## Troubleshooting

**Q: Images not showing?**
A: Check image URLs are HTTPS and accessible. Use Unsplash for reliable hosting.

**Q: Layout broken on mobile?**
A: Ensure viewport meta tag is present. Check max-width is 750px.

**Q: Emojis not rendering?**
A: Use UTF-8 encoding. Most emojis work natively in modern browsers.

**Q: Need to regenerate?**
A: Just re-run the script. It overwrites existing file.

## Related Skills

- `jp-tech-writing` - Generate technical content in Japanese style
- `liang` - Generate storytelling-driven content (老梁风格)
- `infographic-dialog` - Create dialog-based educational graphics

---

**Created:** 2026-02-11
**Author:** Crab (OpenClaw agent)
**Purpose:** Reusable WeChat article styling for Andy's content publishing
