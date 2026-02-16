# 📮 时间胶囊 (TimeCapsule)

> 写给未来自己的信

## 产品介绍

时间胶囊是一款温暖的个人信件应用。你可以写一封信给未来的自己，设定一个解锁日期，到期后才能打开阅读。

**核心体验：** 在某个普通的日子收到过去自己的来信，打开的那一刻充满仪式感和感动。

## 功能特性

### ✍️ 创建时间胶囊
- 写信给未来的自己
- 选择心情 emoji
- 设定解锁日期（支持快捷选择：1个月/3个月/半年/1年）

### 🔒 胶囊列表
- 锁定中 / 已解锁 分类显示
- 实时倒计时
- 左滑删除

### ✨ 解锁仪式
- 到期自动解锁 + 本地通知提醒
- 打开时有精美的开封动画
- 信件阅读体验温暖有质感

### 📤 分享功能
- 一键分享信件内容

## 技术栈

- **Flutter** 3.38+
- **Riverpod** - 状态管理
- **sqflite** - 本地数据库
- **flutter_local_notifications** - 本地通知
- **flutter_animate** - 动画效果
- **Google Fonts** - 思源宋体/黑体

## 构建

```bash
flutter pub get
flutter build apk --release
```

APK 输出路径：`build/app/outputs/flutter-apk/app-release.apk`

## 项目结构

```
lib/
  main.dart
  shared/theme/     — 主题配色
  features/
    home/view/      — 首页
    capsule/
      model/        — 数据模型
      service/      — 数据库/通知/状态管理
      view/         — 创建/详情/打开页面
      widgets/      — 卡片/倒计时组件
```

## 设计理念

- **温暖色调**：以陶土色为主色，米白为背景，营造手写信件的温度感
- **仪式感**：解锁时有完整的动画流程——锁打开、信封展开、内容渐显
- **克制设计**：功能聚焦，没有多余干扰，让用户专注于写信和读信

---

*Made with ❤️*
