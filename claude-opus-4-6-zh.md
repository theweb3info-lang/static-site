# Claude Opus 4.6

> 本文为 [Anthropic 官方博客文章](https://www.anthropic.com/news/claude-opus-4-6) 的简体中文翻译

**2026年2月5日**

---

[![Claude Opus 4.6 介绍视频](https://img.youtube.com/vi/dPn3GBI8lII/maxresdefault.jpg)](https://www.youtube.com/watch?v=dPn3GBI8lII)

**我们正在升级我们最智能的模型。**

全新的 Claude Opus 4.6 在其前代产品的编程能力基础上进行了改进。它规划更加周密，能够持续更长时间的智能体任务，在更大的代码库中运行更加可靠，并且拥有更好的代码审查和调试能力来发现自身的错误。此外，作为我们 Opus 级别模型的首创，Opus 4.6 提供了 **100 万 token 上下文窗口**的测试版。

Opus 4.6 还可以将其增强的能力应用于各种日常工作任务：运行财务分析、进行研究，以及使用和创建文档、电子表格和演示文稿。在 [Cowork](https://claude.com/blog/cowork-research-preview) 中，Claude 可以自主地进行多任务处理，Opus 4.6 能够代替您运用所有这些技能。

该模型在多项评估中达到了最先进的水平。例如：
- 在智能体编程评估 [Terminal-Bench 2.0](https://www.tbench.ai/news/announcement-2-0) 上取得了最高分
- 在 [Humanity's Last Exam](https://agi.safe.ai/)（复杂的跨学科推理测试）中领先于所有其他前沿模型
- 在 [GDPval-AA](https://artificialanalysis.ai/evaluations/gdpval-aa) 上以约 144 个 Elo 分的优势超过 OpenAI 的 GPT-5.2¹²，以 190 分的优势超过 Claude Opus 4.5
- 在 [BrowseComp](https://openai.com/index/browsecomp/) 上的表现优于所有其他模型

正如我们在[系统卡片](https://www.anthropic.com/claude-opus-4-6-system-card)中所展示的，Opus 4.6 还展现了与行业中任何其他前沿模型一样好甚至更好的整体安全特征，在各项安全评估中表现出较低的失配行为率。

---

## 基准测试

### 知识工作
![GDPval-AA 基准测试](https://cdn.sanity.io/images/4zrzovbb/website/6e29759b50e8b3a8363b38b1f573d854df968671-3840x2160.png)
*Opus 4.6 在多个专业领域的真实工作任务中达到了最先进水平。*

### 智能体搜索
![DeepSearchQA 基准测试](https://cdn.sanity.io/images/4zrzovbb/website/018d6d882034d50727948b22e3ad3844a43ee09c-3840x2160.png)
*Opus 4.6 在深度多步骤智能体搜索方面获得了业界最高分。*

### 编程
![Terminal-Bench 2 基准测试](https://cdn.sanity.io/images/4zrzovbb/website/b8cfd7ebd6c82febce5f428f519d68a5dcf5d16f-3840x2160.png)
*Opus 4.6 在真实场景的智能体编程和系统任务中表现出色。*

### 推理
![推理基准测试](https://cdn.sanity.io/images/4zrzovbb/website/b8d511155f209c57e4d6a92ab115ebfc7c8832ff-3840x2160.png)
*Opus 4.6 将专家级推理推向了新前沿。*

---

在 Claude Code 中，您现在可以组建[智能体团队](https://code.claude.com/docs/en/agent-teams)协同完成任务。在 API 上，Claude 可以使用[上下文压缩](https://platform.claude.com/docs/en/build-with-claude/compaction)来总结自身上下文，执行更长时间的任务而不会触及限制。我们还引入了[自适应思考](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking)和新的[努力程度](https://platform.claude.com/docs/en/build-with-claude/effort)控制。

我们对 [Claude in Excel](https://claude.com/claude-in-excel) 进行了大幅升级，并以研究预览的形式发布了 [Claude in PowerPoint](https://claude.com/claude-in-powerpoint)。

[![Claude Opus 4.6 演示](https://img.youtube.com/vi/orTd3grSYsQ/maxresdefault.jpg)](https://www.youtube.com/watch?v=orTd3grSYsQ)

Claude Opus 4.6 现已在 [claude.ai](https://claude.ai)、我们的 API 以及所有主要云平台上提供。如果您是开发者，请通过 [Claude API](https://platform.claude.com/docs/en/about-claude/models/overview) 使用 `claude-opus-4-6`。定价保持不变，为每百万 token 输入 $5 / 输出 $25。

---

## 初步印象

我们用 Claude 构建 Claude。我们的工程师每天都使用 Claude Code 编写代码，每个新模型首先在我们自己的工作中进行测试。使用 Opus 4.6，我们发现模型无需指示就能将更多注意力集中在任务中最具挑战性的部分，快速处理较为简单的部分，以更好的判断力处理模糊问题，并在更长的会话中保持高效。

Opus 4.6 通常会进行更深入的思考，在给出答案之前更仔细地重新审视其推理过程。这在更难的问题上会产生更好的结果，但在较简单的问题上可能会增加成本和延迟。如果您发现模型在某个任务上过度思考，我们建议将努力程度从默认设置（高）调低到中等。您可以通过 `/effort` [参数](https://platform.claude.com/docs/en/build-with-claude/effort)轻松控制。

### 合作伙伴评价

> "Claude Opus 4.6 是 Anthropic 发布的最强模型。它接受复杂请求并真正付诸执行，将其分解为具体步骤、执行并产出精致的工作成果，即使任务非常宏大。对 Notion 用户来说，它感觉不像是一个工具，更像是一个能干的协作者。"
> — **Sarah Sachs**, AI 负责人, Notion

> "早期测试表明，Claude Opus 4.6 在开发者每天面对的复杂多步骤编程工作中表现出色——特别是在需要规划和工具调用的智能体工作流中。这开始解锁前沿的长期任务。"
> — **Mario Rodriguez**, 首席产品官, GitHub

> "Claude Opus 4.6 是智能体规划的一次巨大飞跃。它将复杂任务分解为独立的子任务，并行运行工具和子智能体，并以真正的精确性识别阻碍因素。"
> — **Michele Catasta**, 总裁, Replit

> "Claude Opus 4.6 是我们测试过的最佳模型。它的推理和规划能力在驱动我们的 AI 队友方面表现卓越。它也是一个出色的编程模型——它在大型代码库中导航并识别正确修改的能力达到了最先进水平。"
> — **Amritansh Raghav**, 临时 CTO, Asana

> "Claude Opus 4.6 以我们前所未见的水平推理复杂问题。它考虑到了其他模型遗漏的边缘情况，并始终得出更优雅、更周全的解决方案。"
> — **Scott Wu**, 联合创始人, Cognition

> "Claude Opus 4.6 在 Windsurf 中的表现明显优于 Opus 4.5，特别是在需要仔细探索的任务上，如调试和理解不熟悉的代码库。我们注意到 Opus 4.6 思考时间更长，这在需要更深入推理时是值得的。"
> — **Jeff Wang**, CEO, Windsurf

> "Claude Opus 4.6 在长上下文性能方面代表着一次有意义的飞跃。在我们的测试中，我们看到它以一种一致性水平处理了更大的信息量，这加强了我们设计和部署复杂研究工作流的方式。"
> — **Joel Hron**, 首席技术官, Thomson Reuters

> "在 40 次网络安全调查中，Claude Opus 4.6 在与 Claude 4.5 模型的盲评排名中有 38 次产出了最佳结果。每个模型在相同的智能体框架上端到端运行，最多使用 9 个子智能体和 100 多次工具调用。"
> — **Stian Kirkeberg**, AI 与机器学习负责人, NBIM

> "Claude Opus 4.6 在我们的内部基准测试中是长时间运行任务的新前沿。它在代码审查方面也非常高效。"
> — **Michael Truell**, 联合创始人 & CEO, Cursor

> "Claude Opus 4.6 在 BigLaw Bench 上取得了所有 Claude 模型中最高的 90.2% 分数。40% 的案例获得满分，84% 的案例超过 0.8 分，其法律推理能力令人瞩目。"
> — **Niko Grupen**, AI 研究负责人, Harvey

> "Claude Opus 4.6 在一天内自主关闭了 13 个议题，并将 12 个议题分配给了正确的团队成员，管理一个约 50 人的组织跨 6 个代码仓库。它同时处理了产品和组织决策，同时综合了多个领域的上下文，并且知道何时该升级给人类处理。"
> — **Yusuke Kaji**, AI 总经理, Rakuten

> "Claude Opus 4.6 在设计质量方面是一次提升。它与我们的设计系统完美配合，而且更加自主，这是 Lovable 价值观的核心。"
> — **Fabian Hedin**, 联合创始人, Lovable

> "Claude Opus 4.6 在高推理任务中表现出色，如跨法律、金融和技术内容的多源分析。Box 的评估显示性能提升了 10%，达到 68%（基线为 58%），在技术领域接近满分。"
> — **Yashodha Bhavnani**, AI 负责人, Box

> "Claude Opus 4.6 在 Figma Make 中生成复杂的交互式应用和原型，具有令人印象深刻的创意范围。该模型在第一次尝试中就将详细设计和多层任务转化为代码，为团队探索和构建创意提供了强大的起点。"
> — **Loredana Crisan**, 首席设计官, Figma

> "Claude Opus 4.6 是我们测试过的最好的 Anthropic 模型。它以最少的提示理解意图，并超越预期，探索和创建了一些我不知道自己想要的细节，直到看到它们。感觉就像我在与模型协作，而不是在等待它。"
> — **Paulo Arruda**, 高级工程师, Shopify

> "实际测试和评估都表明，Claude Opus 4.6 在设计系统和大型代码库方面有显著改进，这些用例驱动着巨大的企业价值。它还一次性完成了一个完整功能的物理引擎，在单次传递中处理了一个大型多范围任务。"
> — **Eric Simons**, CEO, Bolt.new

> "Claude Opus 4.6 是我几个月来见过的最大飞跃。我更放心地给它分配一系列跨栈的任务并让它运行。它足够聪明，能够为各个部分使用子智能体。"
> — **Jerry Tsui**, 高级软件工程师, Ramp

> "Claude Opus 4.6 处理了一个数百万行代码库的迁移，就像一位高级工程师一样。它提前规划，在学习过程中调整策略，并以一半的时间完成了任务。"
> — **Gregor Stewart**, 首席 AI 官, SentinelOne

> "我们只在开发者会真正感受到差异时才在 v0 中发布模型。Claude Opus 4.6 轻松通过了这个标准。它的前沿级推理能力，特别是在边缘情况方面，帮助 v0 实现我们的第一目标：让任何人都能将创意从原型提升到生产。"
> — **Zeb Hermann**, v0 总经理, Vercel

> "Claude Opus 4.6 的性能飞跃几乎令人难以置信。对于 Opus [4.5] 来说具有挑战性的真实世界任务突然变得轻而易举。这对 Shortcut 上的电子表格智能体来说感觉是一个分水岭时刻。"
> — **Nico Christie**, 联合创始人 & CTO, Shortcut.ai

---

## 评估 Claude Opus 4.6

在智能体编程、计算机使用、工具使用、搜索和[金融](https://claude.com/blog/opus-4-6-finance)方面，Opus 4.6 是一个行业领先的模型，通常领先幅度很大。

### 基准测试对比表
![基准测试对比表](https://cdn.sanity.io/images/4zrzovbb/website/0e5c55fa8fd05a893d11168654dc36999e90908b-2600x2968.png)

Opus 4.6 在从大量文档集合中检索相关信息方面有了很大提升。这延伸到了长上下文任务，它能在数十万个 token 中保持和追踪信息，漂移更少，并且能发现即使 Opus 4.5 也会遗漏的埋藏细节。

对 AI 模型的一个常见抱怨是"[上下文衰减](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)"，即当对话超过一定数量的 token 时性能会下降。Opus 4.6 的表现明显优于其前代产品：在 [MRCR v2](https://huggingface.co/datasets/openai/mrcr) 的 8 针 100 万变体上——Opus 4.6 得分为 **76%**，而 Sonnet 4.5 仅得分 **18.5%**。这是模型在保持峰值性能的同时能够实际使用多少上下文的质的飞跃。

### 长上下文检索
![长上下文检索](https://cdn.sanity.io/images/4zrzovbb/website/ae7ae61aefff3c9b059975957335785f8ebd59d6-3840x2160.png)

### 长上下文推理
![长上下文推理](https://cdn.sanity.io/images/4zrzovbb/website/9a32a76a983d4c8f709683b38ff3af6664b5128a-3840x2160.png)

### 根因分析
![根因分析](https://cdn.sanity.io/images/4zrzovbb/website/653e04afc43612d3a0f8427da86b6549800005f9-3840x2160.png)
*Opus 4.6 在诊断复杂软件故障方面表现出色。*

### 多语言编程
![多语言编程](https://cdn.sanity.io/images/4zrzovbb/website/542044519014a793cf042a08a730ebd8977c57b0-3840x2160.png)
*Opus 4.6 能跨编程语言解决软件工程问题。*

### 长期一致性
![长期一致性](https://cdn.sanity.io/images/4zrzovbb/website/6c1b33e985bcae9163b77bc25620e85abd5d9a7b-3840x2160.png)
*Opus 4.6 能长时间保持专注，在 Vending-Bench 2 上比 Opus 4.5 多赚取 $3,050.53。*

### 网络安全
![网络安全](https://cdn.sanity.io/images/4zrzovbb/website/8a421f45125743fd9e9078aae992c6e5f236a3da-3840x2160.png)
*Opus 4.6 在代码库中发现真实漏洞的能力优于任何其他模型。*

### 生命科学
![生命科学](https://cdn.sanity.io/images/4zrzovbb/website/f7dff66d47d54dfaabddc82bf9b96658df00634a-3840x2160.png)
*Opus 4.6 在计算生物学、结构生物学、有机化学和系统发育学测试中的表现几乎是 Opus 4.5 的两倍。*

---

## 安全方面的进步

这些智能提升并非以牺牲安全为代价。在我们的自动化行为审计中，Opus 4.6 表现出较低的失配行为率，如欺骗、谄媚、鼓励用户幻想以及配合滥用。总体而言，它与其前代产品 Claude Opus 4.5 一样对齐良好，后者是我们迄今为止对齐最好的前沿模型。Opus 4.6 还展示了所有近期 Claude 模型中最低的过度拒绝率。

![安全评估](https://cdn.sanity.io/images/4zrzovbb/website/569d748607388e6ed42e3ff0ff245d9b0cde6878-3840x2160.png)
*每个近期 Claude 模型在我们自动化行为审计中的整体失配行为得分*

对于 Claude Opus 4.6，我们运行了所有模型中最全面的安全评估集，首次应用了许多不同的测试，并升级了我们之前使用的几项测试。我们新增了用户福祉评估，设置了更复杂的模型拒绝潜在危险请求能力测试，并更新了模型秘密执行有害行为能力的评估。

所有能力和安全评估的详细描述可在 [Claude Opus 4.6 系统卡片](https://www.anthropic.com/claude-opus-4-6-system-card)中找到。

我们还在加速模型的网络**防御**用途，利用它帮助发现和修补开源软件中的漏洞（如我们在新的[网络安全博客文章](https://red.anthropic.com/2026/zero-days/)中所述）。

---

## 产品和 API 更新

### Claude 开发者平台

- **自适应思考** — Claude 可以自行决定何时更深入的推理会有所帮助
- **努力程度** — 四个级别可选：低、中、高（默认）和最大
- **上下文压缩（测试版）** — 自动总结和替换较旧的上下文
- **100 万 token 上下文（测试版）** — 首个具有 100 万 token 上下文的 Opus 级别模型
- **128k 输出 token** — 完成更大输出的任务
- **仅美国推理** — token 定价为 1.1 倍

### 产品更新

在 Claude Code 中以研究预览的形式引入了[智能体团队](https://code.claude.com/docs/en/agent-teams)。您现在可以启动多个智能体作为团队并行工作并自主协调。

Claude in Excel 以改进的性能处理长时间运行和更难的任务。Claude in PowerPoint 现已面向 Max、Team 和 Enterprise 计划以研究预览的形式提供。

---

## 脚注

[1] 由 Artificial Analysis 独立运行。[完整方法论详情](https://artificialanalysis.ai/methodology/intelligence-benchmarking#gdpval-aa)

[2] 这意味着 Claude Opus 4.6 在该评估中约有 70% 的时间获得比 GPT-5.2 更高的分数

**基准测试说明：**
- Terminal-Bench 2.0：除 OpenAI 的 Codex CLI 外，所有运行均使用 Terminus-2 测试框架
- Humanity's Last Exam：Claude 模型使用工具运行时配备了网络搜索、网页获取、代码执行等
- SWE-bench Verified：25 次试验的平均值，通过提示修改达到 81.42%
- BrowseComp：添加多智能体框架后分数提升至 86.8%

---

## 相关内容

- [Claude 是一个思考的空间](https://www.anthropic.com/news/claude-is-a-space-to-think)
- [Apple 的 Xcode 现已支持 Claude Agent SDK](https://www.anthropic.com/news/apple-xcode-claude-agent-sdk)
- [Anthropic 与 Allen 研究所和霍华德·休斯医学研究所合作加速科学发现](https://www.anthropic.com/news/anthropic-partners-with-allen-institute-and-howard-hughes-medical-institute)

---

*© 2026 Anthropic PBC · 本页面为社区翻译，非官方内容*
