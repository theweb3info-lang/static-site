# Japanese-Style Technical Writing Principles (Complete Reference)

## The Nine Core Principles

### Principle 1: Reader First (读者本位)

Always assume your reader is intelligent but unfamiliar with the topic.

**Implementation:**
- Start by stating what prior knowledge is needed (or not needed)
- Constantly ask: "What might confuse the reader right now?"
- Anticipate questions before they arise
- Never make assumptions about what readers "should" know

**Example approach:**
> "Before we dive in, you don't need to know anything about X. We'll build up from the basics together."

---

### Principle 2: Problem-Driven (问题驱动)

Never introduce a concept without first creating a "why do we need this?" moment.

**Implementation:**
- Use questions as chapter/section titles
- Start from the reader's real confusion
- Create a problem before presenting the solution
- Make readers feel the pain before offering the cure

**Bad opening:**
> "Dependency Injection (DI) is a design pattern that implements Inversion of Control (IoC)..."

**Good opening:**
> "Imagine you run a coffee shop. Every morning, you need coffee beans. At first, you go to the market yourself—exhausting. Then you realize: why not have a supplier deliver beans to your door?"

---

### Principle 3: Progressive Disclosure (渐进式展开)

The difficulty curve must be gentle. No jumping!

**Implementation:**
- Each new concept builds only on what's already been explained
- Break complex ideas into small steps
- Make the reader say "Ah, I see!" at each stage
- Never introduce two new concepts simultaneously

**Pattern:**
```
Step 1: Simple version (this works but has a problem)
Step 2: Show the problem (this is why we need something better)
Step 3: Solution (here's how we solve it)
Step 4: Verify (see how it matches step 1's simplicity?)
```

---

### Principle 4: Visual Thinking (视觉化思维)

Use diagrams, flowcharts, and ASCII art to explain.

**What to visualize:**
- Memory as boxes/grids
- Data flow as arrows
- State changes as timelines
- Relationships as connected nodes
- Processes as flowcharts

**ASCII Diagram Example:**
```
【Array】Continuous storage
┌───┬───┬───┬───┬───┐
│ A │ B │ C │ D │ E │
└───┴───┴───┴───┴───┘

【Linked List】Scattered storage
┌───┬─┐   ┌───┬─┐
│ A │→│─→│ B │→│─→...
└───┴─┘   └───┴─┘
```

---

### Principle 5: Analogy First (类比优先)

Every abstract concept needs at least one everyday life analogy.

**Good analogies capture essence, not just surface similarity.**

| Concept | Analogy | Why it works |
|---------|---------|--------------|
| Reference | Library card | Points to book, doesn't contain book |
| Pointer | Delivery tracking number | Address to find something |
| Closure | Memory backpack | Carries context from creation |
| API | Restaurant menu | Interface without implementation |
| Cache | Refrigerator | Pre-stored for quick access |
| Thread | Kitchen worker | Multiple working in parallel |
| Mutex | Bathroom lock | Only one at a time |
| Queue | Line at bank | First come, first served |
| Stack | Plate stack | Last in, first out |
| Recursion | Russian nesting dolls | Contains smaller version of itself |

---

### Principle 6: Terminology Handling (术语处理)

First explain clearly in plain language, then introduce the technical term.

**Implementation:**
- When a term first appears, give a clear definition
- Never pile up jargon
- Never explain jargon with more jargon
- After the plain explanation: "This is called [TERM]"

**Bad:**
> "The singleton pattern ensures a class has only one instance and provides a global point of access to it through lazy initialization."

**Good:**
> "Imagine a printer in an office. There's only one, and everyone shares it. You don't create a new printer each time—you just use the existing one. In programming, we call this the 'singleton pattern.'"

---

### Principle 7: Code Interweaved with Text (代码与文字交织)

Keep code snippets short and focused—demonstrating one concept at a time.

**Implementation:**
- Before code: "Let's try this..."
- Keep under 30 lines, ideally under 15
- After code: "What happened here..."
- Show evolution: simple → problem → solution

**Example structure:**
```markdown
Let's see what happens when we try the simple approach:

[5-10 lines of code]

See that error? That's because [explanation].
Now let's fix it:

[5-10 lines of improved code]

Now it works! The key difference is [explanation].
```

---

### Principle 8: Pursue the Essence (追问本质)

Don't settle for "what is it"—dig into "why was it designed this way?"

**Include:**
- Historical context: Where did this concept come from?
- Problem it solved: What was painful before this existed?
- Design trade-offs: Why choice A instead of B?
- Alternatives: What else could have worked?

**Example:**
> "JavaScript was created in just 10 days in 1995. Brendan Eich had to make quick decisions. That's why [quirk exists]. If he had more time, he might have [alternative]."

---

### Principle 9: Tone and Attitude (语气与态度)

Be warm and patient, like a good teacher beside you.

**Do:**
- Use inclusive language: "we", "let's explore together"
- Acknowledge complexity: "This is tricky, but..."
- Admit limits: "This topic needs another article to fully cover"
- Celebrate understanding: "Now you see why!"

**Don't:**
- Show off knowledge
- Talk down to readers
- Use "obviously" or "trivially"
- Make readers feel stupid

---

## Common Pitfalls to Avoid

| Pitfall | Why it's bad | What to do instead |
|---------|--------------|-------------------|
| Opening with jargon | Scares readers away | Start with relatable scenario |
| "As everyone knows" | Makes non-knowers feel stupid | Explain as if first time |
| Code > 30 lines | Overwhelming, loses focus | Split into smaller chunks |
| Text-only complex process | Hard to follow | Add diagrams |
| Condescending tone | Alienates readers | Be a friend, not a professor |
| Jargon explaining jargon | Compounds confusion | Plain language first |
| Jumping difficulty | Loses readers | Small steps only |
| No "why" | Feels arbitrary | Motivate every concept |

---

## Special Sections That Work Well

### "If You Had to Explain This..." (如果是你，你会怎样解释？)

Imagine explaining to an 8-year-old or grandmother. Forces simplest explanation.

### "Common Misconceptions" (常见误区)

Point out mistakes readers often make. Prevents problems before they happen.

### "The Story Behind the Design" (设计背后的故事)

Share historical context and design decisions. Helps understand "why."

### "What Could Go Wrong" (可能出错的地方)

Show failure modes and how to avoid them. Builds robust understanding.

### "Before and After" (改造前后)

Show code/approach transformation. Makes improvement tangible.

---

## Self-Check Before Publishing

### Content Layer
- [ ] Does opening hook readers within 3 sentences?
- [ ] Does every concept have an analogy or diagram?
- [ ] Did you explain "why it's needed" not just "what it is"?
- [ ] Can code examples be copied and run directly?
- [ ] Did you point out common misconceptions?

### Expression Layer
- [ ] Did you avoid jargon piling?
- [ ] Is every term defined when first introduced?
- [ ] Is the tone warm and friendly, not condescending?
- [ ] Is the difficulty curve smooth?

### Structure Layer
- [ ] Do section titles clearly preview the content?
- [ ] Are paragraphs short enough (under 5 lines)?
- [ ] Are there enough diagrams and code to break up pure text?
- [ ] Does the ending have a summary and extension?

---

## Dialogue Character Guide

### 小白 (Xiaobai) - The Curious Beginner 🐣

**Personality:**
- Enthusiastic and curious
- Not afraid to ask "dumb" questions
- Expresses genuine confusion
- Shows excitement when understanding

**Speech patterns:**
- "Wait, I'm confused about..."
- "Oh! So that means..."
- "But what if...?"
- "Wow, I never thought about it that way!"

### 大维 (Dawei) - The Patient Expert 🦉

**Personality:**
- Patient and encouraging
- Uses lots of analogies
- Never condescends
- Celebrates reader's understanding

**Speech patterns:**
- "Great question! Let me explain..."
- "Imagine if you were..."
- "Let's see what happens when..."
- "Exactly! Now you've got it!"
