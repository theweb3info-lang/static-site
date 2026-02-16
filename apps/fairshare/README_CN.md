# 🏠 FairShare - 家务公平分配

> 让每份付出都被看见 ✨

## 产品简介

FairShare 是一款面向情侣/室友的家务追踪应用。通过积分化和可视化"谁做得多"，解决看不见的劳动（invisible labor）争论。

## 核心功能

### 1. 🏡 创建家庭组
- 创建家庭组，自动生成6位邀请码
- 分享邀请码给家人/室友加入

### 2. 📋 家务清单
- 内置15种常见家务模板（洗碗、拖地、做饭等）
- 每个家务有 emoji 图标和积分值（1-5分）
- 支持自定义添加新家务

### 3. ✅ 一键打卡
- 点击家务即可完成打卡
- 多成员时弹出选择器，记录谁完成了
- 打卡成功有彩纸动画 🎉

### 4. 📊 公平度仪表盘
- 饼图展示每人贡献比例
- 公平度评分（0-100%）
- 友善的提示语："大家都在努力！" / "多帮帮忙吧～"
- 支持本周/本月/全部三种时间范围

### 5. 📝 完成记录
- 按时间倒序查看所有打卡记录
- 显示谁做了什么、得了多少分

### 6. 👨‍👩‍👧‍👦 成员管理
- 查看所有家庭成员
- 添加新成员
- 一键复制邀请码

## 技术栈

- **Flutter 3.38** + **Dart 3.10**
- **Riverpod** 状态管理
- **sqflite** 本地数据库
- **fl_chart** 图表可视化
- **confetti** 打卡动画

## 项目结构

```
lib/
  main.dart              — 应用入口
  app/
    providers.dart       — Riverpod providers
  features/
    home/view/           — 设置页 + 主页
    chores/              — 家务打卡 + 历史记录
    dashboard/view/      — 公平度仪表盘
    members/             — 成员管理
  shared/
    theme/               — 主题配色
    constants/           — 家务模板
    utils/               — 数据库工具
```

## 构建

```bash
flutter pub get
flutter build apk --release
```

APK 输出：`build/app/outputs/flutter-apk/app-release.apk`

## 设计理念

- 🎨 活泼色彩：紫色主色 + 粉色强调色，温暖不幼稚
- 💬 友善语气：绝不引战，鼓励合作
- ⚡ 零学习成本：打开即用，一键打卡
- 🌙 深色/浅色模式自适应
