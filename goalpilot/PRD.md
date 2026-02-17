# GoalPilot — Product Requirements Document

## 一句话定义
GoalPilot 是一款本地优先的目标追踪 App，用 AI 分析你的进度节奏，告诉你该加速还是可以放松。

## 目标用户
- 有量化目标的个人（健身、学习、存钱、写作、编程等）
- 用过习惯打卡 App 但觉得"打卡≠进步"的人
- 不想把数据交给云端的隐私敏感用户

## 核心问题
传统目标 App 只告诉你"完成了多少"，不告诉你"按这个速度能不能按时完成"。用户缺少**节奏感（pace）**——GoalPilot 补上这一块。

---

## 功能规格

### 1. 目标管理

| 字段 | 说明 |
|------|------|
| 名称 | 目标名，如"跑步 500km" |
| 类型 | numeric（累计数值）/ count（计次）/ habit（每日打卡） |
| 目标值 | 数字，如 500 |
| 单位 | km / 次 / 页 / 元 等 |
| 起止日期 | 开始 + 截止 |
| 颜色 | 从预设色板选取 |

**操作：** 新建、编辑、删除（带确认弹窗）

### 2. 进度记录（Log Entry）
- 每条记录：日期 + 数值
- 在目标详情页通过 FAB 快速添加
- 支持历史补录

### 3. AI 进度分析（GoalAnalyzer，纯本地计算）

| 指标 | 说明 |
|------|------|
| currentPace | 实际日均进度 |
| idealPace | 按时完成所需日均进度 |
| isAhead | 当前是否领先于理想线 |
| projectedCompletion | 按当前速度的预计完成日 |
| currentStreak | 连续打卡天数 |
| strongestDay / weakestDay | 一周中表现最好/最差的日子 |
| suggestedDailyTarget | 剩余量÷剩余天数 |
| momentumScore | 近7天 vs 整体均值的比率 |
| summary | 一句话自然语言总结 |

### 4. 页面结构

**首页（HomeScreen）**
- 目标卡片列表，每张显示：名称、进度环、百分比、剩余天数
- 空状态引导
- 右下角 FAB → 新建目标

**新建/编辑目标（AddGoalScreen）**
- 表单：名称、类型、目标值、单位、起止日期、颜色
- 表单校验

**目标详情（GoalDetailScreen）**
- 大进度环 + 关键数字（当前值、目标值、剩余天数）
- Pace 折线图（实际 vs 理想）
- AI 洞察卡片（summary + 各项指标）
- Streak 指示器
- 记录历史列表
- FAB → 添加新记录

### 5. 数据层
- **SQLite**（sqflite），两张表：goals、log_entries
- Provider 状态管理
- 纯本地，零网络依赖

### 6. UI/UX
- 深色主题，Navy 底色 + 渐变高亮（cyan/blue 系）
- Material 3 风格
- 流畅动画（进度环、图表）

---

## 技术栈

| 层 | 选型 |
|----|------|
| 框架 | Flutter (Dart) |
| 状态管理 | Provider |
| 数据库 | sqflite + path |
| 图表 | fl_chart |
| ID | uuid |
| 日期格式化 | intl |

## 平台
MVP 阶段：iOS + Android
代码结构已支持 macOS/Web，后续可按需开启。

---

## MVP 范围（已完成 ✅）

- [x] 3 个页面：首页、新建目标、目标详情
- [x] 5 个组件：ProgressRing、PaceChart、AIInsightsCard、GoalCard、StreakIndicator
- [x] GoalAnalyzer 本地分析引擎
- [x] SQLite 持久化
- [x] 深色主题

## V1.1 规划

- [ ] **通知提醒** — 每日定时提醒记录进度
- [ ] **目标模板** — 预设常见目标（读书50本、跑步1000km 等）
- [ ] **数据导出** — CSV / JSON
- [ ] **Widget** — iOS/Android 桌面小组件显示当前进度
- [ ] **多语言** — 中文 / 英文 / 日文

## V2.0 展望

- [ ] **LLM 集成** — 接本地模型（Gemma/Phi）给出更智能的建议
- [ ] **社交** — 目标分享、好友互相监督
- [ ] **Apple Health / Google Fit** 数据自动同步
- [ ] **订阅制** — Pro 版解锁高级分析和云同步

---

## 竞品差异

| 对比项 | GoalPilot | Habitica | Streaks | Strides |
|--------|-----------|----------|---------|---------|
| Pace 分析 | ✅ 核心功能 | ❌ | ❌ | 部分 |
| AI 洞察 | ✅ 本地 | ❌ | ❌ | ❌ |
| 隐私 | 全本地 | 云端 | iCloud | 云端 |
| 免费 | ✅ | 部分 | 付费 | 付费 |
| 目标类型 | 数值/计次/习惯 | RPG任务 | 习惯 | 多类型 |

## 商业模式
- **免费版**：全功能本地使用
- **Pro（订阅）**：云同步、高级 AI 分析、桌面 Widget、数据导出
- 目标定价：$2.99/月 或 $19.99/年

---

## 成功指标
- App Store 评分 ≥ 4.5
- D7 留存 ≥ 30%
- 月活目标：上线3个月达 5K MAU
