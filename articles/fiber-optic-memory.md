# 200 公里光纤当内存？—— John Carmack 的疯狂实验背后的深刻洞察

## 📌 学习目标

After reading this article, you will understand:
- Why latency is the bottleneck in modern computing
- How fiber optic cable could theoretically work as memory
- What Carmack's proposal reveals about AI architecture
- Why traditional memory hierarchy might be obsolete

读完本文后，你将理解：
- 为什么延迟是现代计算的瓶颈
- 光纤如何在理论上充当内存
- Carmack 的提案揭示了什么关于 AI 架构的洞察
- 为什么传统内存层次可能已经过时

---

## 🎬 Opening: A Tweet That Broke the Internet

> "200 kilometers of fiber would have the same latency as DRAM."
> 
> — John Carmack, 2026

> "200 公里的光纤，延迟和 DRAM 相当。"
> 
> — John Carmack, 2026

When the legendary game developer John Carmack (creator of *Doom* and *Quake*) tweeted this, the internet exploded. Some laughed. Some were confused. A few understood what he was really saying.

当传奇游戏开发者 John Carmack（《毁灭战士》和《雷神之锤》的创造者）发出这条推文时，互联网炸了。有人嘲笑，有人困惑，少数人理解了他真正想说的。

Let me ask you a question: **If I told you that a fiber optic cable stretching from Beijing to Tianjin could replace your computer's RAM, would you believe me?**

让我问你一个问题：**如果我告诉你，一根从北京到天津的光纤可以代替你电脑的内存，你会相信吗？**

Sounds insane, right? But before dismissing it, let's understand what Carmack is actually proposing — and why it's more brilliant than crazy.

听起来很疯狂，对吧？但在否定它之前，让我们先理解 Carmack 实际在提议什么 —— 以及为什么这比疯狂更加睿智。

---

## Part 1: Understanding Latency — The Real Enemy

### What is latency?

Think of latency as **waiting time**. When your brain tells your hand to move, there's a tiny delay before your hand actually moves. That delay is latency.

把延迟想象成**等待时间**。当你的大脑告诉你的手移动时，你的手实际移动之前有一个微小的延迟。那个延迟就是延迟。

In computers, latency is the time between:
1. CPU asking for data: "Give me the value at address 0x1000"
2. Memory responding: "Here it is: 42"

在计算机中，延迟是以下两者之间的时间：
1. CPU 请求数据："给我地址 0x1000 的值"
2. 内存响应："在这里：42"

### The Latency Ladder

Here's how different storage types compare:

以下是不同存储类型的比较：

```
┌────────────────────────────────────────────────┐
│           The Latency Ladder                    │
│           (延迟阶梯)                             │
├────────────────────────────────────────────────┤
│  CPU Register    │ ~0.3ns  │ ▓                 │
│  L1 Cache        │ ~1ns    │ ▓▓                │
│  L2 Cache        │ ~10ns   │ ▓▓▓▓▓             │
│  L3 Cache        │ ~40ns   │ ▓▓▓▓▓▓▓▓          │
│  DRAM (RAM)      │ ~100ns  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   │
│  SSD             │ ~100μs  │ ▓▓▓▓▓▓▓▓... (100x) │
│  HDD             │ ~10ms   │ ▓▓▓▓▓▓... (100,000x)│
└────────────────────────────────────────────────┘
```

Notice the pattern: **Faster = More expensive = Less capacity**

注意这个规律：**更快 = 更贵 = 容量更小**

━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 如果让你向小朋友解释……
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Imagine your desk:
- **Register**: Paper in your hand (instant access)
- **L1 Cache**: Papers on your desk (1 second to grab)
- **RAM**: Files in your drawer (10 seconds to open)
- **SSD**: Files in your cabinet (1 minute to fetch)
- **HDD**: Files in your basement (10 minutes to retrieve)

想象你的书桌：
- **寄存器**：你手里的纸（瞬间访问）
- **L1 缓存**：你桌上的纸（1 秒拿到）
- **RAM**：你抽屉里的文件（10 秒打开）
- **SSD**：你柜子里的文件（1 分钟取出）
- **HDD**：你地下室的文件（10 分钟找到）
━━━━━━━━━━━━━━━━━━━━━━━━━━━

### Why does latency matter?

Because **the CPU is always waiting**. Modern CPUs can execute billions of instructions per second, but if they have to wait 100ns for data from RAM, they spend most of their time doing... nothing.

因为 **CPU 总是在等待**。现代 CPU 每秒可以执行数十亿条指令，但如果它们必须等待 100ns 才能从 RAM 获取数据，它们大部分时间都在做……什么都不做。

This is called the **memory wall** — and it's getting worse every year.

这被称为**内存墙** —— 而且每年都在恶化。

---

## Part 2: The Traditional Memory Hierarchy

### How computers manage memory today

Modern computers use a **pyramid of caches** to hide latency:

现代计算机使用**缓存金字塔**来隐藏延迟：

```
        ┌─────┐
        │ CPU │  ← The brain (大脑)
        └──┬──┘
           │
    ┌──────▼──────┐
    │ L1 Cache    │  ← Smallest, fastest (最小最快)
    │   ~32 KB    │
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │ L2 Cache    │  ← Bigger, slower
    │  ~256 KB    │
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │ L3 Cache    │  ← Even bigger, even slower
    │   ~8 MB     │
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │    DRAM     │  ← Main memory (主内存)
    │   16 GB     │
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │     SSD     │  ← Storage (存储)
    │   1 TB      │
    └─────────────┘
```

### The problem: Power consumption

Here's something that might surprise you: **DRAM is hungry**.

这可能会让你惊讶：**DRAM 很耗电**。

A modern data center spends:
- **40% of power** on DRAM (keeping it refreshed)
- **30% of power** on computation
- **30% of power** on cooling

一个现代数据中心的功耗分布：
- **40% 的功耗**用于 DRAM（保持刷新）
- **30% 的功耗**用于计算
- **30% 的功耗**用于冷却

Why? Because DRAM is **dynamic** — it forgets data every few milliseconds unless refreshed. It's like trying to hold water in your hands: you have to constantly cup them or it leaks out.

为什么？因为 DRAM 是**动态的** —— 它每隔几毫秒就会忘记数据，除非刷新。就像试图用手捧水：你必须不断地合拢双手，否则水会漏掉。

━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ 常见误区
━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ **误区：** "RAM is just storage that happens to be fast."
❌ **误区：** "RAM 只是恰好很快的存储器。"

✅ **真相：** RAM is a **power-hungry, constantly-refreshing, expensive** component that only exists because CPUs need random access.
✅ **真相：** RAM 是一个**耗电、不断刷新、昂贵**的组件，它存在的唯一原因是 CPU 需要随机访问。
━━━━━━━━━━━━━━━━━━━━━━━━━━━

---

## Part 3: Carmack's Proposal — Fiber as Cache

### The crazy idea

John Carmack proposed: **What if we use a loop of fiber optic cable as a cache?**

John Carmack 提议：**如果我们用一圈光纤作为缓存会怎样？**

Here's how it works:

以下是它的工作原理：

```
┌─────────────────────────────────────────────┐
│      Fiber Optic Delay Line Memory          │
│      (光纤延迟线存储器)                       │
├─────────────────────────────────────────────┤
│                                              │
│   ┌───────┐                     ┌───────┐  │
│   │Laser  │ ──→  [Fiber Loop]  ──→│ Photo │  │
│   │Sender │       200 km          │ Det.  │  │
│   └───────┘                     └───────┘  │
│       ▲                              │      │
│       │                              │      │
│       └──────── Data Loop ──────────┘      │
│                                              │
│   Light travels at ~200,000 km/s             │
│   200 km ÷ 200,000 km/s = ~1 ms             │
│   光速约 200,000 公里/秒                     │
│   200 公里 ÷ 200,000 公里/秒 = ~1 毫秒      │
└─────────────────────────────────────────────┘
```

### Wait, 1ms = 100ns?

You might notice: **1 millisecond ≠ 100 nanoseconds**. In fact, 1ms = 1,000,000ns!

你可能注意到了：**1 毫秒 ≠ 100 纳秒**。实际上，1ms = 1,000,000ns！

So how is this "the same latency as DRAM"?

那么这怎么能"和 DRAM 延迟相当"呢？

### The key insight: Sequential access

Here's where Carmack's genius shows: **AI doesn't need random access**.

这就是 Carmack 的天才之处：**AI 不需要随机访问**。

Traditional programs:
```python
# Random access pattern (随机访问模式)
data[5]    # Jump to index 5
data[142]  # Jump to index 142
data[7]    # Jump back to index 7
```

AI inference:
```python
# Sequential access pattern (顺序访问模式)
for weight in model_weights:
    output += weight * input
```

AI reads model weights **in order**, one after another. It's like reading a book: you don't jump randomly between pages, you read page 1, then page 2, then page 3...

AI **按顺序**读取模型权重，一个接一个。就像读书：你不会在页面之间随机跳转，你读第 1 页，然后第 2 页，然后第 3 页……

### How fiber solves this

If you know the data access pattern in advance, you can **pre-load** the fiber loop:

如果你提前知道数据访问模式，你可以**预加载**光纤环：

```
Time 0ms:  Load data[0] into fiber
           (将 data[0] 加载到光纤)

Time 1ms:  data[0] arrives at detector, read it
           CPU requests data[1]
           (data[0] 到达检测器，读取它
            CPU 请求 data[1])

Time 2ms:  data[1] arrives, read it
           CPU requests data[2]
           ...
```

**As long as you request data in order, the latency is effectively 0** — because the next piece of data is already on its way!

**只要你按顺序请求数据，延迟实际上就是 0** —— 因为下一块数据已经在路上了！

━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 设计背后的故事
━━━━━━━━━━━━━━━━━━━━━━━━━━━
**Delay-line memory** isn't new — it was used in early computers in the 1940s!

**延迟线存储器**并不新鲜 —— 它在 1940 年代的早期计算机中就被使用了！

Back then, they used **mercury tubes**: sound waves would travel through liquid mercury, storing data as acoustic pulses.

那时候，他们使用**水银管**：声波会穿过液态汞，将数据存储为声脉冲。

EDSAC (1949) used mercury delay lines to store 512 words of memory. Why? Because DRAM didn't exist yet!

EDSAC（1949）使用水银延迟线存储 512 个字的内存。为什么？因为那时候 DRAM 还不存在！

Carmack's proposal is essentially: **"What if we bring back delay-line memory, but with lasers?"**

Carmack 的提案本质上是：**"如果我们重新使用延迟线存储器，但用激光呢？"**
━━━━━━━━━━━━━━━━━━━━━━━━━━━

---

## Part 4: Why This Makes Sense for AI

### AI's unique access pattern

Traditional CPU workloads are unpredictable:
- Web browser: user clicks random links
- Video game: player moves in any direction
- Database: queries access random rows

传统 CPU 工作负载是不可预测的：
- 网页浏览器：用户点击随机链接
- 电子游戏：玩家向任何方向移动
- 数据库：查询访问随机行

**AI inference is predictable:**
```
For each input:
    1. Load layer 1 weights (顺序读取)
    2. Compute layer 1 output
    3. Load layer 2 weights (顺序读取)
    4. Compute layer 2 output
    ...
```

**AI 推理是可预测的：**
- 加载第 1 层权重（顺序读取）
- 计算第 1 层输出
- 加载第 2 层权重（顺序读取）
- 计算第 2 层输出
- ……

### The power advantage

Light transmission requires almost **no power** to maintain — unlike DRAM, which must be constantly refreshed.

光传输几乎**不需要功耗**来维持 —— 与必须不断刷新的 DRAM 不同。

```
┌──────────────────────────────────────┐
│   Power Comparison (功耗比较)         │
├──────────────────────────────────────┤
│  DRAM 16GB:  ~10W (idle)             │
│              ~15W (active)            │
│                                       │
│  Fiber 200km: ~1W (laser)            │
│               ~2W (amplifiers)        │
│                                       │
│  Savings: ~80%                        │
│  节省：~80%                           │
└──────────────────────────────────────┘
```

In a data center with thousands of servers, this could save **megawatts** of power.

在拥有数千台服务器的数据中心中，这可以节省**数兆瓦**的功率。

### Bandwidth vs. Latency

Here's another insight: **AI cares more about bandwidth than latency**.

这是另一个洞察：**AI 更关心带宽而不是延迟**。

```
CPU mindset:  "I need this ONE piece of data NOW!"
              "我现在需要这一块数据！"
              → Optimizes for low latency
              → 优化低延迟

AI mindset:   "I need this STREAM of data CONTINUOUSLY!"
              "我需要这个数据流持续供应！"
              → Optimizes for high bandwidth
              → 优化高带宽
```

As long as the **data stream never stops**, the absolute latency doesn't matter.

只要**数据流永不停止**，绝对延迟就不重要。

---

## Part 5: The Real Insight — Challenging Assumptions

### What Carmack is really saying

The 200km fiber proposal is a **thought experiment**, not a practical design. Carmack knows this. So what's his point?

200 公里光纤提案是一个**思维实验**，而不是实际设计。Carmack 知道这一点。那么他的重点是什么？

**He's challenging our assumptions about memory hierarchy.**

**他在挑战我们关于内存层次结构的假设。**

━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ 常见误区
━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ **误区：** "DRAM is necessary because it's fast."
❌ **误区：** "DRAM 是必需的，因为它很快。"

✅ **真相：** DRAM exists because CPUs need **random access**. If you don't need random access, you don't need DRAM.
✅ **真相：** DRAM 存在是因为 CPU 需要**随机访问**。如果你不需要随机访问，你就不需要 DRAM。
━━━━━━━━━━━━━━━━━━━━━━━━━━━

### The practical proposal: Flash directly to AI chips

What Carmack actually suggests:
1. Take AI model weights (stored on flash/SSD)
2. Connect flash chips **directly** to AI accelerators
3. Skip DRAM entirely

Carmack 实际建议的做法：
1. 获取 AI 模型权重（存储在闪存/SSD 上）
2. 将闪存芯片**直接**连接到 AI 加速器
3. 完全跳过 DRAM

```
Traditional AI Server:
传统 AI 服务器：

┌─────┐     ┌──────┐     ┌─────┐
│ SSD │ ──→ │ DRAM │ ──→ │ GPU │
└─────┘     └──────┘     └─────┘
            ↑ Bottleneck! (瓶颈！)
            ↑ Power hungry! (耗电！)

Carmack's Vision:
Carmack 的愿景：

┌─────┐                  ┌─────┐
│Flash│ ───────────────→ │ AI  │
│Array│   Direct connect │Chip │
└─────┘   (直接连接)      └─────┘
          ↑ No DRAM needed!
          ↑ 不需要 DRAM！
```

### Why this matters

The AI era is forcing us to rethink **everything**:
- Memory hierarchy (random vs. sequential)
- Power budgets (40% on DRAM is insane)
- Interface standards (PCIe? CXL? Direct?)

AI 时代正迫使我们重新思考**一切**：
- 内存层次结构（随机 vs. 顺序）
- 功耗预算（40% 用于 DRAM 是疯狂的）
- 接口标准（PCIe？CXL？直连？）

━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 设计背后的故事
━━━━━━━━━━━━━━━━━━━━━━━━━━━
**This isn't the first time we've rethought memory.**

**这不是我们第一次重新思考内存。**

In the 1990s, GPUs introduced **unified memory** — CPU and GPU sharing the same RAM. Experts said it was crazy. Today, Apple's M-series chips do exactly this.

在 1990 年代，GPU 引入了**统一内存** —— CPU 和 GPU 共享相同的 RAM。专家说这很疯狂。今天，Apple 的 M 系列芯片正是这样做的。

In the 2000s, Google built datacenters with **no local storage** — everything in RAM or network. Experts said it was wasteful. Today, it's standard for cloud computing.

在 2000 年代，Google 建立了**没有本地存储**的数据中心 —— 一切都在 RAM 或网络中。专家说这是浪费。今天，这是云计算的标准。

**The pattern: When the workload changes, the architecture must change too.**

**规律：当工作负载改变时，架构也必须改变。**
━━━━━━━━━━━━━━━━━━━━━━━━━━━

---

## Summary: The Takeaway

Let's recap what we've learned:

让我们回顾一下我们学到的：

```
┌────────────────────────────────────────────┐
│        Carmack's Fiber Cache Insight        │
│        (Carmack 的光纤缓存洞察)             │
├────────────────────────────────────────────┤
│                                             │
│  ❶ Traditional memory hierarchy assumes     │
│     random access (传统内存层次假设随机访问) │
│                                             │
│  ❷ AI workloads are sequential              │
│     (AI 工作负载是顺序的)                   │
│                                             │
│  ❸ Sequential access doesn't need DRAM      │
│     (顺序访问不需要 DRAM)                   │
│                                             │
│  ❹ Fiber is a thought experiment            │
│     (光纤是思维实验)                        │
│                                             │
│  ❺ Real solution: Flash → AI chip directly  │
│     (真正的解决方案：闪存 → AI 芯片直连)    │
│                                             │
└────────────────────────────────────────────┘
```

### One-sentence takeaway

**In the AI era, memory is no longer "fast random access storage" — it's "continuous data flow."**

**在 AI 时代，内存不再是"快速随机访问存储" —— 而是"持续数据流"。**

### Reflection question

> If you were designing an AI chip today, would you include DRAM support? Or would you design a completely new memory interface?
> 
> 如果你今天设计一个 AI 芯片，你会包括 DRAM 支持吗？还是你会设计一个全新的内存接口？

### Next steps

Want to dive deeper? Explore these topics:
- **CXL (Compute Express Link)**: Industry standard for next-gen memory
- **HBM (High Bandwidth Memory)**: GPU memory architecture
- **Processing-in-Memory (PIM)**: Computing inside the memory chip
- **Optical Interconnects**: Using light for chip-to-chip communication

想深入了解？探索这些主题：
- **CXL（Compute Express Link）**：下一代内存的行业标准
- **HBM（高带宽内存）**：GPU 内存架构
- **内存内计算（PIM）**：在内存芯片内部计算
- **光互连**：使用光进行芯片间通信

---

## 🎓 Final Thought

Carmack's 200km fiber proposal isn't about fiber at all — it's about **questioning defaults**.

Carmack 的 200 公里光纤提案根本不是关于光纤的 —— 而是关于**质疑默认假设**。

When everyone is optimizing DRAM latency, he asks: **"Do we even need DRAM?"**

当所有人都在优化 DRAM 延迟时，他问：**"我们甚至需要 DRAM 吗？"**

That's the mindset of a true systems thinker.

这就是真正的系统思考者的心态。

---

*Written in Japanese-style technical writing (日系风格技术写作)*
*Article length: ~3,500 words | Reading time: ~12 minutes*
*文章长度：约 3,500 字 | 阅读时间：约 12 分钟*
