# 📮 TimeCapsule

> Letters to your future self

## About

TimeCapsule is a warm, personal letter app. Write a letter to your future self, set an unlock date, and open it when the time comes.

**Core Experience:** Receiving a letter from your past self on an ordinary day — the moment of opening is filled with ceremony and emotion.

## Features

### ✍️ Create Time Capsules
- Write letters to your future self
- Choose a mood emoji
- Set unlock date (quick picks: 1 month / 3 months / 6 months / 1 year)

### 🔒 Capsule List
- Locked / Unlocked categories
- Real-time countdown
- Swipe to delete

### ✨ Unlock Ceremony
- Auto-unlock with local push notification
- Beautiful opening animation sequence
- Warm, textured letter reading experience

### 📤 Share
- Share letter content with one tap

## Tech Stack

- **Flutter** 3.38+
- **Riverpod** — State management
- **sqflite** — Local database
- **flutter_local_notifications** — Local notifications
- **flutter_animate** — Animations
- **Google Fonts** — Noto Serif/Sans SC

## Build

```bash
flutter pub get
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
  main.dart
  shared/theme/     — Theme & colors
  features/
    home/view/      — Home page
    capsule/
      model/        — Data model
      service/      — Database / notifications / providers
      view/         — Create / detail / open pages
      widgets/      — Card & countdown widgets
```

## Design Philosophy

- **Warm tones**: Terracotta primary, cream background — evoking handwritten letters
- **Ceremony**: Full animation sequence when unlocking — lock opens, envelope unfolds, content fades in
- **Restraint**: Focused features, no distractions — just writing and reading letters

---

*Made with ❤️*
