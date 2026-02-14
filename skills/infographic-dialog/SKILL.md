---
name: infographic-dialog
description: Generate beautiful Japanese-style dialog infographics from any topic. Creates HTML with two characters (小白 and 大维) explaining concepts, then converts to a single PNG image and delivers via email. Use when user asks to "create educational content", "explain a technical topic", "write Japanese-style tutorial", "generate learning dialogue", or "make a topic easy to understand".
version: 0.3.0
---

# Japanese-Style Technical Writing Skill

Generate educational technical content in the distinctive Japanese textbook style - making complex simple, boring interesting, and abstract concrete.

## Topic History Tracking

**IMPORTANT: Before generating any infographic, always check for duplicates first!**

### History File Location
`~/.openclaw/workspace/skills/infographic-dialog/history.json`

### History File Format
```json
{
  "topics": [
    {
      "topic": "how git works",
      "normalizedTopic": "git",
      "generatedAt": "2025-02-07T03:38:00Z",
      "emailSentTo": "andytest919@gmail.com",
      "fileSize": "2.88 MB"
    }
  ]
}
```

### Step 0: Check Topic History (MANDATORY)

Before generating, **always**:

1. Read `history.json` from the skill directory
2. Normalize the requested topic (lowercase, remove common words like "how", "what is", "explain")
3. Check if a similar topic exists in history
4. **If topic exists**: Ask user "This topic was already generated on [date]. Regenerate? (y/n)"
5. **If topic is new**: Proceed to Step 1

**Duplicate Detection Rules:**
- Exact match on `normalizedTopic`
- Fuzzy match: if >70% of keywords overlap, treat as potential duplicate
- Examples of duplicates:
  - "how git works" ≈ "git explained" ≈ "what is git"
  - "vibe coding" ≈ "what is vibe coding" ≈ "explain vibe coding"

### After Successful Generation

Update `history.json` with the new topic entry:
```bash
# Read, update, write back the history file
```

## Core Philosophy

> 「让复杂的事情变得简单，让枯燥的事情变得有趣，让抽象的事情变得具体。」
> "Make complex things simple. Make boring things interesting. Make abstract things concrete."

## Workflow

### Step 1: Understand the Input & Confirm Outline

The user may provide input in two ways:

**A) Topic only** — User gives a topic string. You research/generate content.

**⚠️ Web Research Rule (MANDATORY for recent topics):**
- If the topic involves technology released/updated **after early 2025** (your training cutoff), you MUST do web research first
- **Use Playwright MCP + Chrome** for web browsing (Andy's Chrome with premium access):
  1. `mcporter call playwright.browser_navigate url=<search-or-article-url>` 
  2. `mcporter call playwright.browser_snapshot` to read content
  3. Repeat for 3-5 high-quality sources (Medium, official blogs, reputable tech sites)
  4. **MUST** `mcporter call playwright.browser_close` when done
- Prefer highly-rated, popular, or authoritative articles
- Synthesize knowledge from multiple sources — don't just copy one article
- Even for pre-2025 topics, consider a quick web search to catch recent developments
- Cite key sources in the outline step so Andy can verify quality

**B) HTML source** — User provides raw HTML code. You extract the content (text, structure, key points) and convert it into our dialog format. **Keep the original content faithful — no adding or removing substance, only reformatting into 小白 × 大维 dialogue style.**

**Before generating HTML, always show a brief outline first and wait for user confirmation:**
- List the planned sections (3-6 bullet points)
- Mention key points/concepts that will be covered
- Note estimated length (short/medium/long)
- Ask: "确认生成？" and wait for OK before proceeding to Step 2

Only proceed to Step 2 after the user confirms.

### Step 2: Generate Dialogue Content

Create a dialogue between two characters:

| Character | Role | Emoji | Style |
|-----------|------|-------|-------|
| 小白 (Xiaobai) | Curious beginner | 🐣 | Asks questions, expresses confusion, shows excitement when understanding |
| 大维 (Dawei) | Patient expert | 🦉 | Explains with analogies, uses visuals, never condescends |

### Step 3: Apply the Nine Principles

1. **Reader First (读者本位)**: Assume intelligent but unfamiliar. Start with what they need to know.

2. **Problem-Driven (问题驱动)**: Never introduce a concept without first creating "why do we need this?" Use questions as section titles.

3. **Progressive Disclosure (渐进式展开)**: Difficulty curve must be gentle. Each concept builds only on what's explained.

4. **Visual Thinking (视觉化思维)**: Use ASCII diagrams, flowcharts, tables. Draw memory as boxes, data flow as arrows.

5. **Analogy First (类比优先)**: Every abstract concept needs an everyday life analogy.

6. **Terminology Handling (术语处理)**: Plain language first, then introduce the term. Never pile jargon.

7. **Code Interweaved (代码与文字交织)**: Short code snippets (<30 lines). "Let's try..." before, "What happened..." after.

8. **Pursue Essence (追问本质)**: Not just "what" but "why designed this way?"

9. **Warm Tone (语气与态度)**: Like a patient friend. Use "we" and "let's explore."

### Step 4: Generate HTML

Use the template at `assets/template.html` to generate a styled HTML file.

**HTML Structure Components:**

```html
<!-- Section Divider -->
<div class="section-divider">
  <span>💬 Section Title</span>
</div>

<!-- Chat Row - NEW LAYOUT (Avatar + Name above bubble) -->
<!-- Left = Xiaobai -->
<div class="chat-row left">
  <div class="chat-content">
    <div class="chat-header">
      <div class="chat-avatar">🐣</div>
      <div class="chat-name">小白</div>
    </div>
    <div class="chat-bubble">Message here</div>
  </div>
</div>

<!-- Right = Dawei -->
<div class="chat-row right">
  <div class="chat-content">
    <div class="chat-header">
      <div class="chat-avatar">🦉</div>
      <div class="chat-name">大维</div>
    </div>
    <div class="chat-bubble">Message here</div>
  </div>
</div>

<!-- Highlight Box -->
<div class="highlight-box">Key concept here</div>

<!-- Compare Grid -->
<div class="compare-grid">
  <div class="compare-card bad"><h4>❌ Bad</h4><p>...</p></div>
  <div class="compare-card good"><h4>✅ Good</h4><p>...</p></div>
</div>

<!-- Demo Box (for code/diagrams) -->
<div class="demo-box"><pre>Code or ASCII art</pre></div>

<!-- Principle Card -->
<div class="principle-card"><h4>Title</h4><p>Content</p></div>

<!-- Big Quote -->
<div class="big-quote">Memorable quote here</div>

<!-- Summary Box -->
<div class="summary-box">
  <h3>📝 Summary Title</h3>
  <div class="summary-item">
    <span class="summary-num">1</span>
    <span>Point here</span>
  </div>
</div>

<!-- Analogy Table -->
<table class="analogy-table">
  <tr><th>Concept</th><th>Analogy</th></tr>
  <tr><td>Term</td><td>🎯 Everyday comparison</td></tr>
</table>
```

### Step 5: Save and Capture Single Image

**Output: ONE seamless image, max 10MB**

1. Write the HTML to `/tmp/{topic-name}.html`
2. Run the single-image capture script:

```bash
node ~/.openclaw/workspace/skills/infographic-dialog/scripts/html2image.js /tmp/{topic-name}.html /tmp/{topic-name}.png
```

3. Check file size - if exceeds 10MB, shorten content and regenerate

## Output Files

Generate these files:
1. `{topic-name}.html` - The styled dialogue content
2. `{topic-name}.png` - Single full-page screenshot (max 10MB)

**Always save a copy of the HTML to `output/{topic-name}.html`** in the skill directory and git commit, so all generated work is tracked and recoverable.

## Content Patterns to Use

### Title Pattern

标题要**吸引人但不夸张**，有场景感和好奇心：

❌ **太平淡：** "OpenClaw 文件介绍"
❌ **太夸张：** "震惊！99%的人不知道的秘密！"
✅ **刚刚好：** "装完 OpenClaw，冒出来 8 个文件，都是干嘛的？"
✅ **刚刚好：** "Git 用了三年，我才真正搞懂它的原理"

### Opening Hook Pattern

开头要有**铺垫和场景感**，不要上来就介绍概念。先制造共鸣，再引出主题。

❌ **Never start with:**
> "X is a Y that does Z..."
> "OpenClaw 有以下文件..."

✅ **Always start with a relatable scenario:**
> "最近 OpenClaw 太火了，我装完一看——工作区里冒出来一堆 .md 文件，这都是啥？"
> "用了三年 Git，突然被人问 rebase 和 merge 有什么区别，我竟然答不上来……"

### The "Aha!" Moment Pattern

Build each section to culminate in an insight:
1. Present a problem or confusion
2. Explore it together
3. Reveal the elegant solution
4. Celebrate understanding ("看到了吗？See?")

### Code Evolution Pattern

Show code transforming through stages:
1. Naive/simple version
2. Problem with that version
3. Improved version
4. Why the improvement works

## Example Dialogue Flow

```
Section: What is X?
  Xiaobai: Asks about X with curiosity
  Dawei: Creates context/problem first
  Xiaobai: Shows relatable confusion
  Dawei: Introduces analogy
  Xiaobai: Expresses partial understanding
  Dawei: Adds code/diagram
  Xiaobai: Has "aha!" moment

Section: Why do we need X?
  [Similar pattern...]

Section: Summary
  Xiaobai: Asks for recap
  Dawei: Provides memorable takeaways
  [Summary box with key points]
```

## Things to AVOID

- ❌ Opening with jargon definitions
- ❌ Using "obviously," "trivially," "as everyone knows"
- ❌ Code blocks longer than 30 lines
- ❌ Pure text for complex processes (must have diagrams)
- ❌ Condescending or showing-off tone
- ❌ Explaining jargon with more jargon

## Large Content Handling

**Before generating HTML**, if the source content is very large (e.g. 9+ sections, 30+ key points, or would clearly exceed 10MB as a single image), **ask the user first** whether to:
- Split into 2-3 parts (Part 1 / Part 2 / Part 3)
- Or trim/condense into a single image

**Do not auto-split or auto-trim.** Always ask.

## If Image Exceeds 10MB

When the screenshot exceeds 10MB, **regenerate shorter HTML content**:

1. **Identify what to trim:**
   - Reduce number of dialogue exchanges (keep 3-4 per section instead of 5-6)
   - Simplify ASCII diagrams (fewer lines)
   - Combine related sections
   - Remove redundant examples
   - Keep only the most essential summary points

2. **Content length guidelines for ~10MB limit:**
   - **Short topic**: 3-4 sections, ~15-20 chat exchanges total
   - **Medium topic**: 4-5 sections, ~20-25 chat exchanges total
   - **Long topic**: 5-6 sections, ~25-30 chat exchanges total (may need trimming)

3. **Regenerate and re-capture:**
   - Update the HTML file with shortened content
   - Take new screenshot
   - Verify size is under 10MB

4. **If still too large after trimming content:**
   - Reduce image quality: use JPEG instead of PNG
   - Or split into 2 parts (Part 1 / Part 2) as separate articles

## WeChat QR Code (Required)

**Always include the WeChat QR code image at the bottom of every infographic!**

Add this before the footer in every HTML:

```html
<!-- WeChat QR -->
<div style="margin: 20px 0; text-align: center;">
  <img src="/Users/andy_crab/.openclaw/workspace/skills/infographic-dialog/assets/wechat_xiaoheiwu.png" 
       style="width: 100%; max-width: 690px; border-radius: 15px;" 
       alt="技术小黑屋 公众号" />
</div>
```

Asset location: `assets/wechat_xiaoheiwu.png`

## CSS Rules for Screenshots

**NEVER use these in infographic HTML (causes content duplication in screenshots):**
- ❌ `background-attachment: fixed`
- ❌ `min-height: 100vh` on body (use no min-height instead)

**Always set on `html` element:**
```css
html { background: #24243e; }
```

## Quality Checklist

Before delivering the final image:
- [ ] Single continuous image (no splits)
- [ ] File size ≤ 10MB
- [ ] Text is crisp and readable on mobile
- [ ] All emojis render correctly
- [ ] No content cut off at edges
- [ ] WeChat QR code image at the bottom
- [ ] No background gradient repetition

## Step 6: Deliver Image via Email

Send email with the single image attachment:

```bash
cat << 'EOF' | himalaya template send
From: theweb3info@gmail.com
To: andytest919@gmail.com
Subject: 🎨 [Topic] - Infographic

Hi!

Here's the infographic explaining [Topic].

<#part filename=/tmp/{topic-name}.png name={topic-name}.png><#/part>
EOF
```

**Default email recipient:** andytest919@gmail.com

**Note:** Do NOT send images to Telegram. Only deliver via email.

## Step 7: Confirm Delivery

After sending, confirm to user:
- ✅ Email sent to andytest919@gmail.com
- 📎 Single full-page image attached
- 📏 File size (should be under 10MB)

## Assets

- **`assets/template.html`** - Complete HTML template with CSS styling (WeChat optimized, 690px width)
- **`references/writing-principles.md`** - Detailed writing principles reference
- **`scripts/html2image.js`** - Single full-page screenshot script
