# 洗车店就在家门口 50 米，我问 AI 怎么去，它说"走过去"—— 为什么 AI 会集体翻车？

![cover](https://images.unsplash.com/photo-1485463611174-f302f6a5c1c9?w=1200&q=80)

## 📌 你会学到什么

After reading this article, you will understand:
- Why AI gives "correct" answers that are actually useless
- How Large Language Models actually work (and what they can't do)
- The difference between pattern matching and reasoning
- Why AI lacks "common sense"

读完本文后，你将理解：
- 为什么 AI 给出"正确"但无用的答案
- 大语言模型的实际工作原理（以及它们做不到什么）
- 模式匹配与推理的区别
- 为什么 AI 缺乏"常识"

---

## 🎬 Opening: A Real Conversation

Let me share a conversation I had with AI yesterday:

让我分享昨天和 AI 的一段对话：

> **我：** "洗车店距离我家 50 米，我怎么过去？"
> 
> **ChatGPT：** "很简单！直接走过去就可以了，50 米大约是 1 分钟的步行距离。"
> 
> **我：** "......"

Sounds reasonable, right? The AI gave a **correct** answer.

听起来很合理，对吧？AI 给出了一个**正确的**答案。

**But here's the twist: I was asking because I wanted to drive.**

**但问题是：我问这个问题，是因为我想开车去。**

I was sitting in my car, about to navigate to the car wash 50 meters away. I asked the AI how to get there, expecting it to say something like:

我当时坐在车里，准备导航去 50 米外的洗车店。我问 AI 怎么去，期待它说：

> "It's too close to navigate. Just look out the window and drive straight ahead."
> 
> "太近了，不需要导航。直接往前开就能看到。"

Instead, it told me to **walk**.

但它告诉我**走过去**。

**Why did the AI fail at such a simple question?**

**为什么 AI 在这么简单的问题上翻车了？**

---

## Part 1: AI "Said" the Right Thing, But Didn't "Think"

### The illusion of understanding

When ChatGPT told me to "walk there," it wasn't wrong. Walking 50 meters is perfectly reasonable advice — **if you're a pedestrian**.

当 ChatGPT 告诉我"走过去"时，它并没有错。走 50 米是完全合理的建议 —— **如果你是个行人的话**。

The problem is: **AI didn't understand the context**.

问题是：**AI 没有理解上下文**。

It saw:
- Distance: 50 meters
- Question: "How do I get there?"
- Pattern: Short distance → walking

它看到了：
- 距离：50 米
- 问题："我怎么过去？"
- 模式：短距离 → 走路

And it matched the pattern. But it missed the **intent** behind my question.

它匹配了模式。但它错过了我问题背后的**意图**。

━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 如果让你向小朋友解释……
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Imagine asking a classmate: "How do I get to the cafeteria?"

想象你问同学："我怎么去食堂？"

**Smart classmate:** Looks at you, sees you're in a wheelchair, says "Take the elevator."

**聪明的同学：** 看着你，注意到你坐轮椅，说"坐电梯。"

**AI classmate:** Doesn't look at you, just says "Walk there."

**AI 同学：** 不看你，直接说"走过去。"

**Why? Because AI doesn't "see" you — it only sees text.**

**为什么？因为 AI 不会"看"你 —— 它只看到文字。**
━━━━━━━━━━━━━━━━━━━━━━━━━━━

---

## Part 2: How LLMs Actually Work — The Token Prediction Machine

### AI is not "thinking," it's "predicting"

Let's understand what's really happening when you talk to ChatGPT, Claude, or any Large Language Model.

让我们理解当你和 ChatGPT、Claude 或任何大语言模型对话时，实际发生了什么。

**AI is fundamentally a next-word prediction machine.**

**AI 本质上是一个预测下一个词的机器。**

Here's how it processes your question:

以下是它如何处理你的问题：

```
Input (输入):
"洗车店距离我家 50 米，我怎么过去？"

Tokenization (分词):
["洗车店", "距离", "我家", "50", "米", "，", "我", "怎么", "过去", "？"]

AI's internal process (AI 的内部处理):
┌────────────────────────────────────┐
│  Token 1: "洗车店"                  │
│  Token 2: "距离"                    │
│  Token 3: "我家"                    │
│  Token 4: "50"                      │
│  Token 5: "米"  ← Oh, short distance│
│  ...                                │
│  Token 10: "？" ← Question mark     │
│                                     │
│  Pattern detected (检测到模式):     │
│  [Short distance] + [How to get]   │
│                                     │
│  Most likely response (最可能的回复):│
│  → "走过去" (walk there)            │
└────────────────────────────────────┘
```

**It's not reasoning. It's pattern matching.**

**这不是推理。这是模式匹配。**

### What AI sees vs. what you mean

When you type: "洗车店距离我家 50 米，我怎么过去？"

当你输入："洗车店距离我家 50 米，我怎么过去？"

**What you mean (你的意思):**
- I'm in my car (我在车里)
- I need to drive there (我需要开车去)
- I'm asking if it's too close to navigate (我在问是否近到不需要导航)

**What AI sees (AI 看到的):**
- Distance = 50 meters (距离 = 50 米)
- Question word = "怎么" (how)
- Context = None (上下文 = 无)

```
┌───────────────────────────────────────┐
│         Human Reasoning               │
│         (人类推理)                     │
├───────────────────────────────────────┤
│  Question → Context → Intent → Answer │
│                                        │
│  "怎么去？"                            │
│     ↓                                  │
│  He's asking about car wash            │
│     ↓                                  │
│  Probably wants to drive               │
│     ↓                                  │
│  "太近了，直接开过去"                  │
└───────────────────────────────────────┘

┌───────────────────────────────────────┐
│         AI Processing                 │
│         (AI 处理)                      │
├───────────────────────────────────────┤
│  Tokens → Pattern → Most likely token │
│                                        │
│  ["50", "米", "怎么", "去"]            │
│     ↓                                  │
│  Pattern: short_distance + travel      │
│     ↓                                  │
│  Most common answer: "走过去"          │
└───────────────────────────────────────┘
```

**See the difference? Humans reason from intent. AI matches patterns.**

**看到区别了吗？人类从意图推理。AI 匹配模式。**

---

## Part 3: Why AI Lacks "Common Sense"

### The missing piece: Physical world model

AI has read billions of words, but it has never:
- Sat in a car (坐过车)
- Walked 50 meters (走过 50 米)
- Seen a car wash (见过洗车店)

AI 读过数十亿个单词，但它从未：
- 坐过车
- 走过 50 米
- 见过洗车店

**It has no model of the physical world.**

**它没有物理世界的模型。**

Let's break down what "common sense" actually means:

让我们分解一下"常识"实际意味着什么：

━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 Common Sense = Physical World + Social Norms + Implicit Knowledge
📖 常识 = 物理世界 + 社会规范 + 隐含知识
━━━━━━━━━━━━━━━━━━━━━━━━━━━

#### 1. Physical World Knowledge (物理世界知识)
```
✅ Human knows (人类知道):
- Cars are used for distances > 50m if you're already in one
- Walking is for pedestrians
- You don't get out of your car to walk 50m

❌ AI doesn't know (AI 不知道):
- What it's like to be inside a car
- That getting out would be inconvenient
- That the question implies "I'm in a car"
```

#### 2. Social Norms (社会规范)
```
✅ Human knows:
- Asking "how to get there" for 50m implies special context
- Normal people don't need help for 50m walks
- Therefore, question probably about driving

❌ AI doesn't know:
- Social implications of questions
- What's "obvious" vs. "needs asking"
```

#### 3. Implicit Knowledge (隐含知识)
```
✅ Human infers:
- Question about car wash → probably driving
- Already knows location → asking about navigation
- 50m is awkward for navigation apps

❌ AI infers:
- Nothing. Only processes explicit text.
```

### The "Gorilla in the basketball court" problem

There's a famous psychology experiment where people watch a video of a basketball game and are asked to count passes. Most people miss the **gorilla** walking through the scene because they're focused on counting.

有一个著名的心理学实验，人们观看篮球比赛的视频并被要求数传球次数。大多数人都错过了穿过场景的**大猩猩**，因为他们专注于计数。

**AI is worse. It not only misses the gorilla — it doesn't even know what a gorilla is.**

**AI 更糟。它不仅错过了大猩猩 —— 它甚至不知道大猩猩是什么。**

━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ 常见误区
━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ **误区：** "AI can learn common sense from more training data."
❌ **误区：** "AI 可以从更多训练数据中学到常识。"

✅ **真相：** Common sense requires **embodied experience**. You can't learn what sitting in a car feels like from text alone.
✅ **真相：** 常识需要**具身体验**。你无法仅从文本中学会坐在车里是什么感觉。

**No amount of reading about swimming will teach you how to swim.**
**读再多关于游泳的文字，都学不会游泳。**
━━━━━━━━━━━━━━━━━━━━━━━━━━━

---

## Part 4: More "AI翻车" Examples — When Pattern Matching Fails

Let's look at similar cases where AI gives "correct but useless" answers:

让我们看看类似的案例，AI 给出"正确但无用"的答案：

### Example 1: The Strawberry Problem

> **Question:** How many 'r's are in the word "strawberry"?
> **问题：** "strawberry" 这个词里有几个字母 'r'？
> 
> **GPT-4 Answer:** "There are two 'r's in strawberry."
> **GPT-4 回答：** "strawberry 里有两个 'r'。"
> 
> **Correct Answer:** Three. (st**r**awbe**rr**y)
> **正确答案：** 三个。(st**r**awbe**rr**y)

**Why it failed:** AI doesn't "see" letters. It sees tokens. "strawberry" is one token, not 10 letters.

**为什么翻车：** AI 不"看"字母。它看 token。"strawberry" 是一个 token，不是 10 个字母。

### Example 2: The Reverse Text Problem

> **Question:** Reverse the word "apple"
> **问题：** 反转单词 "apple"
> 
> **AI Answer:** "elppa" ✅
> **AI 回答：** "elppa" ✅
> 
> **Question:** Reverse the word "ChatGPT"
> **问题：** 反转单词 "ChatGPT"
> 
> **AI Answer:** "TPGtahC" ❌ (Correct: "TPGtahC" but often gets it wrong)
> **AI 回答：** "TPGtahC" ❌ (正确答案是 "TPGtahC"，但经常答错)

**Why it struggles:** Token-level processing makes character manipulation difficult.

**为什么困难：** Token 级处理使字符操作变得困难。

### Example 3: The Bigger Number Problem

> **Question:** Which is bigger: 9.11 or 9.9?
> **问题：** 哪个更大：9.11 还是 9.9？
> 
> **Early GPT Answer:** "9.11 is bigger because it has more digits."
> **早期 GPT 回答：** "9.11 更大，因为它有更多数字。"
> 
> **Correct Answer:** 9.9 (9.11 = nine point eleven, not nine hundred eleven)
> **正确答案：** 9.9（9.11 = 九点一一，不是九百一十一）

**Why it failed:** Pattern matching "more digits = bigger" without understanding decimals.

**为什么翻车：** 模式匹配"更多数字 = 更大"，不理解小数。

### Example 4: The 50-meter Car Wash (Our Case)

> **Question:** "洗车店距离我家 50 米，我怎么过去？"
> 
> **AI Answer:** "走过去。"
> 
> **What I meant:** "I'm in my car, is it too close to navigate?"

**Pattern: short distance + "how to get there" → walking**

**模式：短距离 + "怎么过去" → 走路**

---

## Part 5: What This Tells Us About AI

### AI is a "Savant" — Genius in some areas, clueless in others

Think of AI as a person with **Savant Syndrome** — extraordinary abilities in specific domains, but lacking basic common sense.

把 AI 想象成一个患有**学者综合症**的人 —— 在特定领域有非凡能力，但缺乏基本常识。

```
┌─────────────────────────────────────┐
│        AI's Superpowers (超能力)     │
├─────────────────────────────────────┤
│ ✅ Writing code                      │
│ ✅ Translating languages             │
│ ✅ Summarizing documents             │
│ ✅ Answering factual questions       │
│ ✅ Pattern recognition               │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│        AI's Blind Spots (盲区)       │
├─────────────────────────────────────┤
│ ❌ Physical world reasoning          │
│ ❌ Context understanding             │
│ ❌ Common sense judgment             │
│ ❌ Intent inference                  │
│ ❌ Embodied experience               │
└─────────────────────────────────────┘
```

### The paradox: More data ≠ More understanding

OpenAI trained GPT-4 on:
- Billions of web pages (数十亿网页)
- Books, papers, code (书籍、论文、代码)
- Conversations (对话)

OpenAI 用以下内容训练 GPT-4：
- 数十亿网页
- 书籍、论文、代码
- 对话

**But it still doesn't know that you don't walk 50 meters to a car wash when you're already in your car.**

**但它仍然不知道，当你已经在车里时，你不会走 50 米去洗车店。**

Why? Because **knowing ≠ understanding**.

为什么？因为**知道 ≠ 理解**。

━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 设计背后的故事
━━━━━━━━━━━━━━━━━━━━━━━━━━━
**The "Chinese Room" Argument (1980)**

**"中文房间"论证（1980）**

Philosopher John Searle proposed: Imagine a person in a room with a rulebook for translating Chinese. They receive Chinese questions, follow the rules, and produce Chinese answers.

哲学家 John Searle 提出：想象一个人在房间里，有一本翻译中文的规则书。他们收到中文问题，按照规则，产生中文答案。

**Do they understand Chinese? No. They're just following rules.**

**他们理解中文吗？不。他们只是在遵循规则。**

**That's what LLMs do. They follow statistical rules, but they don't "understand."**

**这就是 LLM 所做的。它们遵循统计规则，但它们不"理解"。**
━━━━━━━━━━━━━━━━━━━━━━━━━━━

---

## Part 6: How to Work With AI's Limitations

### Give explicit context

Instead of: "洗车店距离我家 50 米，我怎么过去？"

Instead of: "洗车店距离我家 50 米，我怎么过去？"

Try: "我现在在车里，洗车店距离我家 50 米。我需要导航吗？"

Try: "我现在在车里，洗车店距离我家 50 米。我需要导航吗？"

**Be explicit about:**
- Your current state (我在车里)
- Your intent (我想开车去)
- Your actual question (太近了需要导航吗？)

**明确说明：**
- 你的当前状态（我在车里）
- 你的意图（我想开车去）
- 你的实际问题（太近了需要导航吗？）

### Understand what AI is good at

```
✅ Use AI for:
- Text generation (写代码、文案)
- Pattern recognition (分类、总结)
- Knowledge retrieval (查找信息)
- Translation (翻译)

❌ Don't rely on AI for:
- Common sense judgment (常识判断)
- Physical world reasoning (物理推理)
- Nuanced social context (微妙的社交语境)
- Intent understanding (意图理解)
```

### Verify, don't trust blindly

When AI gives you an answer, ask yourself:

当 AI 给你一个答案时，问问自己：

- **Does this make sense in context?** (这在上下文中合理吗？)
- **Did I provide enough information?** (我提供了足够的信息吗？)
- **Is AI just pattern matching?** (AI 只是在匹配模式吗？)

**AI is a tool, not an oracle.**

**AI 是工具，不是神谕。**

---

## Summary: Why AI "翻车" on Simple Questions

Let's recap what we learned:

让我们回顾一下我们学到的：

```
┌─────────────────────────────────────────┐
│    Why AI Fails at "50m Car Wash"       │
│    (为什么 AI 在"50 米洗车店"上翻车)     │
├─────────────────────────────────────────┤
│                                          │
│  ❶ AI doesn't understand context        │
│     (AI 不理解上下文)                    │
│                                          │
│  ❷ AI is a pattern matcher, not a       │
│     reasoner (AI 是模式匹配器，不是推理器)│
│                                          │
│  ❸ AI lacks physical world model        │
│     (AI 缺少物理世界模型)                │
│                                          │
│  ❹ AI can't infer implicit intent       │
│     (AI 无法推断隐含意图)                │
│                                          │
│  ❺ Common sense requires embodied       │
│     experience (常识需要具身体验)        │
│                                          │
└─────────────────────────────────────────┘
```

### One-sentence takeaway

**AI is incredible at pattern matching, but terrible at common sense — because it has never experienced the physical world.**

**AI 在模式匹配方面令人难以置信，但在常识方面很糟糕 —— 因为它从未体验过物理世界。**

### Reflection question

> Next time you ask AI a question, try asking yourself: "Did I give it enough context to understand my **intent**, not just my **words**?"
> 
> 下次你问 AI 一个问题时，试着问问自己："我是否给了它足够的上下文来理解我的**意图**，而不仅仅是我的**词语**？"

### What's next?

Want to dive deeper? Explore these topics:
- **Embodied AI**: Robots learning through physical interaction
- **Multimodal Models**: GPT-4V, Gemini (can "see" images)
- **Common Sense Reasoning**: COMET, ConceptNet projects
- **The Symbol Grounding Problem**: How to connect words to meaning

想深入了解？探索这些主题：
- **具身 AI**：通过物理交互学习的机器人
- **多模态模型**：GPT-4V、Gemini（可以"看"图像）
- **常识推理**：COMET、ConceptNet 项目
- **符号接地问题**：如何将词语连接到意义

---

## 🎓 Final Thought

The 50-meter car wash problem isn't a bug — it's a feature.

50 米洗车店问题不是一个 bug —— 这是一个特性。

**It reminds us that AI is a tool built for pattern matching, not a mind that understands the world.**

**它提醒我们，AI 是一个为模式匹配而构建的工具，而不是一个理解世界的心智。**

The day AI says: "Wait, you're asking about a car wash while in your car. It's 50 meters away — just look outside and drive straight. You don't need navigation."

当 AI 说："等等，你在车里问洗车店怎么走。它就在 50 米外 —— 看看窗外，直接开过去。你不需要导航。"

**That's the day AI has common sense.**

**那一天，AI 才有了常识。**

**We're not there yet.**

**我们还没到那一步。**

---

*Written in Japanese-style technical writing (日系风格技术写作) adapted for WeChat 公众号*
*Article length: ~2,800 words | Reading time: ~10 minutes*
*文章长度：约 2,800 字 | 阅读时间：约 10 分钟*
