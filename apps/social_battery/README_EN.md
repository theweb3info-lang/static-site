# 🔋 Social Battery Manager

> A social energy management tool for introverts

## 📱 Overview

Social Battery is an app designed for introverts to visually manage their social energy. It displays your "social battery" through an intuitive battery icon, tracks social activities, suggests rest times, and provides conversation topic cards and exit excuses.

## ✨ Core Features

### 1. Battery Dashboard 🔋
- Visual battery icon (CustomPainter)
- Battery level from 100%→0% with animations
- Status-based suggestions
- Quick charge/drain buttons

### 2. Activity Logging 📝
- 10 social activity types
- Custom duration and energy cost
- Notes for recording feelings

### 3. Social Calendar 📅
- Weekly social load bar chart (fl_chart)
- Activity list management

### 4. Topic Cards 💬
- 30+ curated small talk topics
- Card flip animation
- One-tap copy

### 5. Exit Excuse Generator 🏃
- 25+ fun and practical exit excuses
- Random pick
- One-tap copy

### 6. Weekly Report 📊
- Activity count / total drain / duration stats
- Activity type ranking
- Personalized insights

## 🛠 Tech Stack

- **Framework**: Flutter 3.38
- **State Management**: Riverpod
- **Local Storage**: sqflite
- **Charts**: fl_chart
- **Battery Animation**: CustomPainter

## 📁 Project Structure

```
lib/
  app/          — App entry, home page
  features/     — Feature modules
    dashboard/  — Battery dashboard
    activities/ — Social activity logging
    calendar/   — Social calendar
    topics/     — Topic cards
    excuses/    — Exit excuses
    report/     — Weekly report
  shared/       — Shared modules
    theme/      — Theme configuration
    utils/      — Utilities/Providers
    constants/  — Constants & data
```

## 🚀 Build & Run

```bash
# Get dependencies
flutter pub get

# Run debug
flutter run

# Build release APK
flutter build apk --release
```

## 🎨 Design

- Dark/Light mode support
- Brand colors: Purple (#6C5CE7) + Cyan (#00CEC9)
- Dynamic battery color based on level
- Smooth transition animations
- Material Design 3

---

*v1.0.0 — 2026-02-16*
