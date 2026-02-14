---
layout: post
title: "Claude Opus 4.6 发布：百万上下文 + 智能体编程新高度"
date: 2026-02-06 06:00
comments: true
categories: AI Claude Anthropic LLM Agent
---

Anthropic 发布 Claude Opus 4.6，首个支持 **100 万 token 上下文窗口**的 Opus 级别模型，智能体编程能力显著提升。

<!--more-->

## 核心升级

### 编程能力

- **规划更周密**：复杂任务分解为独立子任务，并行执行
- **长时间智能体任务**：大型代码库中运行更可靠
- **代码审查与调试**：自动发现自身错误

### 上下文处理

- **100 万 token 上下文（测试版）**：首个 Opus 级别长上下文模型
- **上下文衰减大幅改善**：MRCR v2 8 针 100 万变体得分 **76%**（Sonnet 4.5 仅 18.5%）
- **128k 输出 token**：支持更大输出任务

---

## 基准测试表现

| 评估项 | 表现 |
|--------|------|
| Terminal-Bench 2.0 | 智能体编程最高分 |
| Humanity's Last Exam | 跨学科推理第一 |
| GDPval-AA | 超 GPT-5.2 约 144 Elo，超 Opus 4.5 约 190 Elo |
| BrowseComp | 全模型最佳 |

---

## API 使用

模型名称：

```
claude-opus-4-6
```

定价（每百万 token）：

```
输入：$5
输出：$25
```

### 新增 API 功能

- **自适应思考**：模型自行决定何时深入推理
- **努力程度控制**：低 / 中 / 高（默认）/ 最大
- **上下文压缩（测试版）**：自动总结旧上下文
- **仅美国推理**：定价 1.1 倍

---

## 产品更新

### Claude Code

新增 **智能体团队（研究预览）**：启动多个智能体并行协作。

### Office 集成

- **Claude in Excel**：处理长时间运行任务性能提升
- **Claude in PowerPoint（研究预览）**：Max / Team / Enterprise 可用

---

## 安全特性

- 失配行为率低于或等于 Opus 4.5
- 过度拒绝率为近期 Claude 模型最低
- 详见 [系统卡片](https://www.anthropic.com/claude-opus-4-6-system-card)

---

## 总结

Opus 4.6 三个关键点：百万上下文、智能体编程领先、安全对齐不打折。适合复杂代码库操作和长时间智能体任务。

---

**可用渠道**：[claude.ai](https://claude.ai) / API / 各主要云平台

**原文**：[Anthropic 官方博客](https://www.anthropic.com/news/claude-opus-4-6)
