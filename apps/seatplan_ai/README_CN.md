# 💒 SeatPlan AI - 婚礼座位AI优化器

智能婚礼座位安排工具，输入宾客关系和约束条件，AI自动优化座位方案。

## ✨ 核心功能

1. **宾客管理** - 添加宾客姓名、关系标签（家人/朋友/同事/VIP等）
2. **约束设置** - 设置必须同桌、不能同桌、VIP靠前等约束
3. **桌位配置** - 自定义桌数和每桌人数
4. **AI优化排座** - 一键运行模拟退火+贪心算法，自动生成最优座位方案
5. **可视化座位图** - 圆桌俯视图，支持拖拽微调宾客位置
6. **导出分享** - 导出为图片或文字方案，一键分享

## 🧠 算法原理

采用两阶段优化：
- **阶段一：贪心初始分配** - 优先处理VIP和强约束宾客，按约束评分选择最佳桌位
- **阶段二：模拟退火优化** - 2000次迭代，通过随机交换宾客位置，逐步降温找到全局最优解

评分维度：
- 硬约束满足（必须同桌/不能同桌）
- VIP前排优先
- 桌位人数均衡
- 同标签宾客聚合

## 🎨 设计风格

- 暖玫瑰色主色调，金色强调色，婚礼氛围
- 支持深色/浅色模式
- Material Design 3

## 🛠 技术栈

- Flutter 3.38+
- Riverpod 状态管理
- CustomPainter 座位图绘制
- 模拟退火优化算法
- share_plus 分享功能

## 📦 构建

```bash
flutter pub get
flutter build apk --release
```

APK输出: `build/app/outputs/flutter-apk/app-release.apk`

## 📂 项目结构

```
lib/
  app/          — App入口、路由、Provider
  features/
    guests/     — 宾客管理
    constraints/— 约束设置
    settings/   — 桌位配置
    seating/    — 座位优化与可视化
    export/     — 导出分享
  shared/
    theme/      — 主题配色
```
