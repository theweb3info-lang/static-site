# MEMORY.md — Long-Term Memory

## Andy
- TZ: Asia/Singapore | Blog: droidyue.com | Email test: andytest919@gmail.com
- Focus: AI content creation | 公众号 ~2700 followers (2026-02-15)
- 2026春节 = 马年（丙午），注意不要用蛇年内容

## Infra
- Mac mini (Apple Silicon, 24GB) | Claude CLI (separate account) | Qwen (free)
- Static hosting: GitHub Pages (theweb3info-lang.github.io/static-site/)

## Cron Jobs (错开并发)
- 06:00 每日热点深度文章（viral-tech skill, job b9ea562a）
- 07:00 Elon summary → g-elonmusk
- 07:30 AI 厂商研究报告
- 08:00 AI Hot Topics 早报 → g-ideas
- 08:30 🇺🇸 每日App创意（job fe3b5e42）→ 私聊Andy
- 09:00 🇯🇵 日本App创意（job 8924c121）+ OpenClaw Best Practices
- 09:30 🇰🇷 韩国App创意（job 9ea457f7）+ Daily TODO
- 10:00 🇩🇪 德语区App创意（job cceef40b）+ AI Money Stories
- 10:30 🇧🇷 拉美App创意（job 61ea0b4e）
- 11:00 🇸🇦 中东App创意（job f913b770）
- 21:00 每日Agent日报（私聊Andy，Sonnet，job 6568ed14）
- 22:00 AI Hot Topics 晚报 → g-ideas
- 23:00 Medium AI Top 10 → g-medium
- 每1.5h 明治人物篇配图
- 每2h 明治藩篇写作 + 事件/文化/对比篇
- 每2h 系统报告（sonnet）
- App创意格式：每区域1个/天，含市场验证+乐观/保守收益+Andy优劣势

## Report Rule
- 任务完成时，说明用了什么执行：主Agent / Sub-agent / Claude CLI / Qwen / Copilot
- 回复要带细节（Andy 是程序员，想了解执行过程）

## Rules
- static-site 有新内容时，同步更新 `static-site/all.html` 索引页（加对应链接）
- 脚本用 Python，不用 bash
- 轻量搜索用 LiteBrowse（browser-mcp），替代 Brave Search API
- 深度浏览/复杂操作用 Playwright MCP + Chrome（mcporter call playwright.*）

## viral-tech Skill
- 路径: skills/viral-tech/SKILL.md
- 爆款公式：选题筛选→标题公式→结构模板→校对清单
- 不要用 Part 1/Part 2 编号
- 校对：事实核查+类比审核，修复后才能保存

## Article Quality Rules (Andy feedback 2026-02-13)
- 先介绍主题是什么，不要假设读者知道
- 写作指令（角度一/二）不要出现在正文
- 信息不要重复出现
- 事实核查：不过度引申
- Benchmark数据用最新的
- 论证严谨，分析别人言论时要有来源
- 不要用 Part 1/Part 2 等标记，直接用标题

## App出海项目（2026-02-16启动）
- 270个创意（100英语+33日本+35韩国+32德语区+35拉美+35中东）
- 4个产品方案：AllerScan、MCPHub、SubZap、NudgeMate
- Flutter项目搭建中：`keigo-master/`（敬语转换）+ `allerscan/`（过敏原扫描）
- 计划：2周敬語マスター → 2周AllerScan → 第4周上架
- 目标：Mac Studio ¥15K-30K

## Lessons
- Heavy tasks → spawn sub-agent, don't do in main session
- Never use `gateway config.get/config.schema` — use jq on openclaw.json
- Use `gateway config.patch` directly
- Claude CLI needs `claude login` first

## Workflow Notes
- 搜索优先用 LiteBrowse（browser-mcp），替代 Brave Search API
- 深度浏览/登录操作用 Playwright MCP + Chrome（mcporter call playwright.*）
- Andy偏好 mcporter 调用（不是内置browser工具）
- 文章要有独特角度，不要写成标准科技新闻

## Claude CLI Skills (Quick Ref)
- `/liang` — 老梁故事汇风格
- `/sspai-review` — 少数派测评文风格（产品深度测评、分层推荐、第一人称实测）
- `/jp-tech-writing` — 日系技术写作
- `/infographic-dialog` — 对话式信息图
- `/wechat-article` — 微信公众号文章
- `/wechat-viral` — 公众号爆文（大佬言论+科普+升华）

## TODO System
- **Taskwarrior** 3.4.2 (`task` CLI) — installed 2026-02-13
- Config: `~/.taskrc` | Data: `~/.task/`
- Cron: Daily 9:00 SGT reminder (job `696e2b3b`)
- Andy interacts conversationally, I run task commands

## Bing Image Creator (文章配图)
- 脚本：`scripts/bing-image-gen.py`（Playwright + Edge profile）
- venv：`~/.openclaw/workspace/venv-playwright/`
- Profile：`~/.openclaw/bing-creator-profile/`（从 Edge 复制的 cookies）
- 用法：`source venv-playwright/bin/activate && python3 scripts/bing-image-gen.py "prompt" -o ./images/目录`
- 免费 DALL-E 3，每次生成4张图
- 注意：Bing 会受时间热点影响，prompt 要具体
- 文章配图流程：我构思 prompt → exec 调脚本 → 下载图片 → 发给 Andy

## Tools
- infographic-dialog, render-and-send.sh, himalaya, Edge TTS
- Liang pipeline: liang-meiji/ → static-site/meiji/
- LiteBrowse (browser-mcp): 轻量浏览器MCP，mcporter名=`browser-mcp`
  - 9个工具：search, navigate, getText, evaluate, screenshot, setBrowser, waitForUser, rateLimitStats
  - 搜索：`mcporter call 'browser-mcp.search(query: "xxx", engine: "duckduckgo", language: "zh")'`
  - 抓内容：`mcporter call 'browser-mcp.getText(url: "https://xxx", maxChars: 5000)'`
  - 切引擎：`mcporter call 'browser-mcp.setBrowser(engine: "chromium")'`（默认webkit）
  - 默认：maxResults=10, language=en, page=1, headed=false, 缓存1h, 30次/h/引擎
  - Google被反爬，优先用Bing/DuckDuckGo
