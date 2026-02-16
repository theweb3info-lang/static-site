# MCPHub — MCP Server 管理器产品计划

## 📛 产品名称

**MCPHub** — Your MCP Server Command Center

备选：MCPDesk / ServerFlow / MCPilot

---

## 🎯 核心问题

MCP（Model Context Protocol）生态正在爆发式增长，但用户面临巨大痛点：
- **发现难**：没有好用的 MCP server 搜索/浏览工具
- **安装难**：需要手动 clone、build、配置环境变量
- **配置难**：手动编辑 `claude_desktop_config.json` 等 JSON 文件，一个逗号错误就崩溃
- **管理难**：无法一目了然看到所有 server 的状态、版本、资源占用
- **升级难**：没有自动更新机制，手动 git pull + rebuild

竞品现状：
- **mcp.so**：仅静态目录，无安装/管理功能
- **各 IDE 内置**：极其原始，只能手动编辑 JSON
- **无真正的管理工具**：市场空白

---

## 🏗️ 核心功能

### MVP（V1）— 2-3 周

| 功能 | 说明 |
|------|------|
| 🔍 Server 目录 | 内置可搜索的 MCP server 目录，支持分类、评分、标签 |
| ⚡ 一键安装 | 选择 server → 自动下载/build/配置，零命令行 |
| 📋 配置管理 | 可视化编辑 MCP 配置，自动同步到 Claude/Cursor/Windsurf |
| 🔄 多客户端支持 | 自动检测已安装的 MCP 客户端，统一管理配置 |
| 📊 Server 状态面板 | 查看所有 server 的运行状态、日志、资源占用 |
| 🗑️ 一键卸载 | 清理 server 及相关配置 |

### V2 — 第2-3个月

| 功能 | 说明 |
|------|------|
| 🔄 自动更新 | 监测 server 新版本，一键/自动升级 |
| ⭐ 社区评分 | 用户评分、评论、使用统计 |
| 🧪 Server 测试台 | 内置测试工具，安装前可试用 server 功能 |
| 📦 配置导入/导出 | 一键备份/恢复/分享整套 MCP 配置 |
| 🔐 安全扫描 | 自动检查 server 权限、网络请求、安全风险 |
| 🤖 AI 推荐 | 根据用户工作场景智能推荐 server 组合 |
| 📊 使用分析 | 哪些 server 用得最多、响应最快 |

### V3 — 第4-6个月

| 功能 | 说明 |
|------|------|
| 🏪 Server 市场 | 开发者可上架付费 server，平台抽成 |
| 🔧 Server 开发工具 | 内置脚手架、调试器、发布工具 |
| 👥 团队管理 | 企业级配置同步、权限管理 |
| ☁️ 云端同步 | 多设备配置同步 |

---

## 🛠️ 技术架构

### 客户端：Flutter Desktop + Web

```
┌─────────────────────────────────────┐
│          Flutter UI Layer           │
│  (macOS / Windows / Linux / Web)    │
├─────────────────────────────────────┤
│        Business Logic Layer         │
│  - Server Discovery & Search       │
│  - Installation Engine              │
│  - Config Manager (JSON R/W)        │
│  - Process Manager (start/stop)     │
│  - Update Checker                   │
├─────────────────────────────────────┤
│        Platform Layer (FFI/CLI)     │
│  - File System Access               │
│  - Process Spawning (npm/pip/cargo) │
│  - System Tray Integration          │
│  - Native Notifications             │
├─────────────────────────────────────┤
│        Local Storage                │
│  - SQLite (server catalog cache)    │
│  - Hive (user preferences)         │
└─────────────────────────────────────┘
```

### 后端（轻量）

```
┌────────────────────────────────┐
│     Cloudflare Workers API     │
│  - Server 目录 (GitHub sync)   │
│  - 用户账号 & 订阅              │
│  - 评分 & 评论                  │
│  - 使用统计（匿名）            │
├────────────────────────────────┤
│     Cloudflare D1 + R2         │
│  - 数据库 + 静态资源            │
└────────────────────────────────┘
```

### 为什么选 Flutter？
- **跨平台**：一套代码 → macOS/Windows/Linux/Web
- **桌面体验好**：原生窗口、系统托盘、文件操作
- **开发速度快**：Andy 已有 Flutter 经验
- **Web 版本**：可作为在线目录 + 配置生成器

---

## 💰 商业模式

### Free 版
- 浏览完整 server 目录
- 安装/卸载 server（无限制）
- 管理最多 5 个 server
- 支持 1 个 MCP 客户端
- 基础状态监控

### Pro 版 — $9.99/月 或 $79.99/年

- **无限 server 管理**
- **多客户端同步**（Claude + Cursor + Windsurf 等）
- **自动更新**
- **配置备份/导入导出**
- **安全扫描**
- **AI 推荐**
- **使用分析面板**
- **优先支持**

### 收入预估

| 阶段 | 时间 | 用户量 | 付费率 | 月收入 |
|------|------|--------|--------|--------|
| 发布初期 | 月1-2 | 1,000 | 5% | $500 |
| 增长期 | 月3-4 | 5,000 | 8% | $4,000 |
| 稳定期 | 月5-6 | 15,000 | 10% | $15,000 |
| 成熟期 | 月7-12 | 50,000 | 10% | $50,000 |

---

## 🚀 上市策略 (Go-to-Market)

### 第一阶段：开发者社区渗透（月1-2）
1. **Product Hunt 首发** — 精心准备 launch，目标前3
2. **Hacker News** — Show HN 帖子
3. **Reddit** — r/ClaudeAI, r/cursor, r/LocalLLaMA
4. **Twitter/X** — AI 开发者 KOL 合作
5. **GitHub** — 开源核心组件，吸引 star

### 第二阶段：内容营销（月2-4）
1. **YouTube 教程** — "How to manage MCP servers like a pro"
2. **博客 SEO** — 针对 "MCP server setup", "Claude MCP config" 等关键词
3. **Discord 社区** — 建立用户社群
4. **MCP server 作者合作** — 帮他们在 MCPHub 上架

### 第三阶段：增长飞轮（月4-6）
1. **用户 referral 计划** — 邀请送 Pro 时长
2. **企业版试用** — 针对开发团队
3. **与 MCP 客户端合作** — 成为推荐管理工具

### 关键指标
- Week 1: 500 下载
- Month 1: 2,000 用户
- Month 3: 10,000 用户
- Month 6: 30,000+ 用户

---

## 🥊 竞争分析

| 维度 | MCPHub | mcp.so | 手动配置 | IDE内置 |
|------|--------|--------|----------|---------|
| 发现 server | ✅ 搜索+推荐 | ✅ 静态目录 | ❌ 靠搜索 | ❌ 无 |
| 一键安装 | ✅ | ❌ | ❌ | ❌ |
| 可视化配置 | ✅ | ❌ | ❌ | ❌ 只有JSON |
| 多客户端管理 | ✅ | ❌ | ❌ 手动复制 | ❌ 单一 |
| 状态监控 | ✅ | ❌ | ❌ | 基础 |
| 自动更新 | ✅ Pro | ❌ | ❌ | ❌ |
| 安全扫描 | ✅ Pro | ❌ | ❌ | ❌ |

### 护城河
1. **先发优势** — 市场空白，6-12个月窗口期
2. **社区效应** — 评分、评论、使用数据越积越多
3. **集成深度** — 对各客户端配置格式的深入支持
4. **Andy 的 MCP 协议专长** — 技术理解比潜在竞争者更深

---

## 📅 开发时间线

### Week 1-2：核心基础
- [ ] Flutter 桌面项目搭建
- [ ] Server 目录数据源（爬取 GitHub awesome-mcp-servers）
- [ ] 搜索/浏览 UI
- [ ] 配置文件读写引擎（支持 Claude Desktop JSON 格式）

### Week 3：安装引擎
- [ ] npm/npx server 自动安装
- [ ] pip/uvx server 自动安装
- [ ] Docker server 支持
- [ ] 环境变量配置 UI

### Week 4：管理功能
- [ ] Server 启动/停止/重启
- [ ] 状态监控面板
- [ ] 日志查看器
- [ ] 一键卸载

### Week 5-6：上线准备
- [ ] Landing page 完善
- [ ] Product Hunt 准备
- [ ] Beta 测试（邀请制）
- [ ] macOS 签名/公证
- [ ] Windows 安装包

### Month 2-3：迭代
- [ ] Pro 版功能
- [ ] 支付集成（Stripe）
- [ ] 多客户端支持
- [ ] 自动更新

---

## 🎯 Andy 的优势

1. **MCP 协议深度理解** — 知道每个 server 类型的配置细节
2. **Flutter 跨平台经验** — 快速出 MVP
3. **开发者社区网络** — 能快速获得早期用户反馈
4. **全栈能力** — 前端+后端+部署一人搞定
5. **时间窗口** — MCP 生态快速增长，但管理工具缺失，6-12个月先发优势

---

## ⚠️ 风险 & 应对

| 风险 | 概率 | 应对 |
|------|------|------|
| IDE 厂商内置类似功能 | 中 | 保持跨客户端优势，做得更深更好 |
| MCP 协议大变 | 低 | 紧跟规范更新，快速适配 |
| 用户增长慢 | 中 | 开源核心吸引贡献者，内容营销持续 |
| 竞品出现 | 中 | 先发+社区数据+深度集成构建壁垒 |

---

*最后更新：2026-02-16*
*作者：Andy*
