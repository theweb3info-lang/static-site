# The Billion-Dollar CEO Still Coding: Why Tobi Lütke Won't Stop Programming

![Cover](cover)

While most CEOs of hundred-billion-dollar companies are busy attending board meetings and making strategic decisions, Shopify founder and CEO Tobi Lütke just released a new open-source project on GitHub—QMD (Query Markup Documents). This isn't some enterprise-level strategic tool, but rather a local document search engine built to solve his own daily workflow pain points.

==Why is a CEO managing a company worth hundreds of billions still writing code himself?==

━━━

## 💡 More Than a CEO: Tobi Lütke the Programmer

Tobi Lütke has never been a traditional CEO. When he and his partners created Shopify in 2006, the motivation was simple: to build a better e-commerce platform for his girlfriend's snowboard shop. The existing solutions were either too expensive or lacked necessary features, so he decided to build it himself using Ruby on Rails.

Twenty years later, Shopify has grown into the world's second-largest e-commerce platform, supporting millions of merchants with a market cap that once exceeded $200 billion. Yet Tobi still maintains his programmer's identity—his GitHub account (@tobi) remains active, where you can regularly see him committing code and participating in technical discussions.

The recently open-sourced QMD project is a product of his effort to solve personal workflow problems.

:::intro
In the AI era, what does it mean when a CEO writes code? This isn't just about technical passion—it's about deep thinking on future working methods.
:::

━━━

## 🔍 QMD: Beyond Search—Knowledge Management for the AI Age

QMD stands for "Query Markup Documents," which sounds academic but is essentially a highly practical local document search engine. It addresses a very specific problem:

**In an information-overloaded age, how do you quickly find notes, meeting records, and documents scattered everywhere?**

### Technical Architecture: Triple-Pronged Search Strategy

QMD employs a quite advanced three-layer search architecture:

1. **Keyword Search (BM25)** - Traditional, reliable full-text retrieval
2. **Semantic Search (Vector)** - Understanding content meaning, finding relevant documents that don't necessarily contain keywords
3. **Hybrid Mode (LLM Reranking)** - Using large language models to intelligently rank search results

This design is interesting. Most search tools either only do keywords or go all-in on semantic search, but Tobi chose the fusion route. The thinking behind this: ==Different types of queries require different search strategies, and truly useful tools should deliver optimal results without users noticing==.

### Tool Designed for AI Agents

More notably, QMD was designed from the ground up for AI workflows:

- **MCP (Model Context Protocol) Integration** - Direct seamless collaboration with Claude Desktop, Claude Code, and other AI tools
- **JSON and File Output** - Optimized for programmatic calls, not just human reading
- **Local Execution** - Faster response while protecting privacy

:::data
**QMD Technical Specs**
• Based on Bun + Node.js ecosystem
• Uses node-llama-cpp and GGUF models
• Supports both stdio and HTTP MCP transport
• Collection management for multiple knowledge bases
• Completely local execution, no data upload
:::

━━━

## 🤔 Deep Thinking: The Three-Fold Significance of CEOs Coding

### First Layer: Maintaining Technical Acuity

In an era of rapid technological iteration, if CEOs completely disconnect from code, they easily lose intuitive feel for technological development. By writing code himself, Tobi can:

- **Directly experience new technologies** - Like GGUF models and MCP protocols in this case
- **Understand implementation complexity** - Know what features are easy to build versus requiring massive engineering investment
- **Feel developer experience** - Think about products and tools from an engineer's perspective

This "hands-on" approach gives him more confidence when making technical strategy decisions, avoiding being misled by engineering teams' over-optimism or conservatism.

### Second Layer: Validating Product Philosophy

The QMD project is actually Tobi's exploration of future working methods. He believes:

==The future of work isn't humans directly operating tools, but humans coordinating various tools through AI Agents to complete tasks==

This philosophy directly influenced QMD's design:
- Why choose MCP over REST API? Because MCP is specifically designed for AI Agents
- Why emphasize local execution? Because in Agent workflows, both latency and privacy are crucial
- Why optimize output formats? Because this data is mainly for AI processing, not human viewing

By personally implementing this tool, Tobi can validate whether his judgment about future working models is correct.

### Third Layer: Organizational Culture Symbol

At Shopify, Tobi's coding isn't a personal hobby but a cultural symbol. It conveys several important messages:

**Technology First**: Even CEOs must be accountable for code quality
**Flat Organization**: No one is above specific work due to high position
**Rapid Iteration**: Solve problems immediately when discovered, don't go through complex processes

This culture is common in startups but maintaining it in a hundred-billion-dollar company isn't easy.

━━━

## 🏢 Comparison: Other Tech Leaders' Choices

Interestingly, different tech leaders have completely different attitudes toward "writing code":

**The Still-Coding Camp:**
- **John Carmack** (Oculus/Meta) - Still an active graphics programming expert
- **Drew Houston** (Dropbox CEO) - Often participates in core product development
- **Daniel Ek** (Spotify CEO) - Still reviews important code

**The Management Transition Camp:**
- **Mark Zuckerberg** - Wrote PHP early on, now focuses on products and strategy
- **Elon Musk** - Basically stopped direct programming after the PayPal period
- **Jeff Bezos** - Transitioned to complete management role after Amazon's early days

Neither choice is right or wrong, but they reflect different management philosophies:

==The former believes CEOs need to maintain direct control over products, while the latter thinks CEOs should focus on strategy and personnel management==

Tobi clearly belongs to the former. He once said: "If I can't understand Shopify's technical implementation, I can't make the best decisions for merchants."

━━━

## 🚀 AI Era Trend: Programming is Getting Easier

The QMD project also reveals an interesting phenomenon: AI is lowering programming barriers.

Look at QMD's tech stack:
- Uses Bun (next-generation JavaScript runtime with excellent developer experience)
- Based on node-llama-cpp (out-of-the-box local LLM solution)
- Adopts GGUF models (standardized model format, easy to use)

These tools share a common characteristic: **low development barriers and small integration costs**. An experienced programmer could probably build a QMD-like prototype in just a few days.

:::intro
As programming becomes easier, we might see more CEOs picking up keyboards again. Not because of technical nostalgia, but because it's the most direct way to validate ideas.
:::

### New CEO Profile?

In the AI-assisted development era, the cost of CEO coding is dramatically decreasing:
- **GitHub Copilot** provides code completion
- **Claude/GPT** can explain complex logic
- **Modern development tools** reduce configuration complexity

This might spawn new CEO profiles:
- Don't need to be programming experts, but should be able to read and modify code
- Validate ideas through prototypes rather than just documents and meetings
- Directly experience new technologies, maintaining sensitivity to industry trends

━━━

## 💭 QMD's Inspiration: Tools Should Serve Workflows

Returning to QMD itself, this project's most valuable aspect isn't the technical implementation, but the design thinking.

### Starting from User Needs

Tobi didn't pursue technology for technology's sake. His starting point was simple:
- **Problem**: Documents scattered everywhere, low search efficiency
- **Scenario**: Need quick information access during writing, meetings, decision-making
- **Constraints**: Privacy matters, can't rely on cloud services

Only then did he consider which technologies to use for solutions. This approach is actually uncommon in large company product teams—many projects start with technical solutions, then find application scenarios.

### Designing for Workflows, Not Features

Another characteristic of QMD is **workflow orientation**:

Traditional search tool design logic: User inputs query → Returns result list → User selects and clicks

QMD's design logic: AI Agent receives task → Calls QMD to get relevant documents → Completes task based on document content

This difference seems subtle but determines the product's core value. ==The former is an information retrieval tool, the latter is part of a workflow process==.

━━━

## 🎯 Insights for Entrepreneurs and Managers

Tobi's QMD project gives us several important insights:

### 1. Maintain Control Over Details

Even in large companies, CEOs should have intuitive understanding of core business implementation specifics. This doesn't mean micromanaging, but having the ability to judge technical solution reasonableness.

### 2. Use Prototypes to Validate Ideas

Rather than spending lots of time in meetings discussing, quickly build a prototype and try it. In the AI-assisted development era, this cost is already quite low.

### 3. Design for the Future, Not Present

QMD targets not the current document management market, but future AI Agent workflows. This forward-thinking mindset is worth learning.

### 4. Tools Should Serve Workflows

Don't pursue technology for cool tech's sake, but ask: How does this tool truly improve users' working methods?

━━━

## 🌟 Conclusion: A New Standard for Tech Leaders

Tobi Lütke's open-sourcing of QMD isn't an earth-shattering event, but it symbolizes a new tech leadership style:

**Having both strategic vision and implementation capability**  
**Understanding both business logic and technical logic**  
**Both managing teams and validating ideas**

In an AI-reshaping-everything era, such leaders might have more advantages. They won't be left behind by rapid technological changes, nor will they make wrong decisions by being disconnected from reality.

==True tech leaders aren't those who only talk concepts, but those who can personally validate concepts through hands-on work==.

Tobi Lütke uses his GitHub code to tell us: No matter how successful you become, never stop learning and creating. This might just be the secret to staying competitive.

**Project URL:** https://github.com/tobi/qmd  
**Related Technologies:** MCP, GGUF, node-llama-cpp, Bun

---

*In this era of endless AI tools, QMD reminds us: the best tools often come from real needs, not flashy technology.*

![Section](section-technology)