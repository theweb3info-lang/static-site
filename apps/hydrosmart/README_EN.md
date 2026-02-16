# 💧 HydroSmart — Smart Hydration Reminder

> Dynamically adjusts hydration goals based on activity, weather & caffeine — not just "drink every 2 hours."

## Features

### 🎯 Smart Daily Goal
- Base calculation: body weight × 35ml/kg
- Activity level multiplier (1.0× sedentary → 1.6× very active)
- Weather adjustment: +15% when >30°C, +5% when >25°C (via Open-Meteo API)
- +150ml per cup of coffee consumed

### ⚡ One-Tap Quick Logging
- 4 preset amounts: Small (150ml), Cup (250ml), Large (500ml), Bottle (750ml)
- Satisfying press animation feedback
- Instant snackbar confirmation

### 📊 Daily Progress Ring
- Animated circular progress indicator
- Turns green with 🎉 celebration on goal completion
- Shows current intake / goal amount / percentage

### ☕ Caffeine Tracker
- +/- buttons to log coffee cups
- Automatically adjusts daily water goal

### 📈 7-Day History
- Bar chart showing past week's intake
- Dashed goal line overlay
- Green bars for days goal was met
- Today's records list with swipe-to-delete

### 🌓 Dark / Light Mode
- System default, manual light, or manual dark
- Complete design system with proper contrast ratios

## Usage Flow

1. **First launch** → Set weight & activity level → Tap "Get Started"
2. **Daily use** → Tap a cup-size button on home screen to log water
3. **View history** → Tap 📊 icon in top right
4. **Had coffee?** → Use the caffeine tracker card at bottom of home screen
5. **Adjust settings** → Tap ⚙️ icon to change weight/activity/theme

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter 3.38 | Cross-platform framework |
| Riverpod | State management |
| shared_preferences | Local data persistence |
| fl_chart | Bar charts |
| http | Weather API requests |
| Open-Meteo API | Free weather data |

## Project Structure

```
lib/
  main.dart                    — Entry point
  app/app.dart                 — App config, routing, theming
  features/
    home/view/home_page.dart   — Home (progress ring + quick log)
    home/widgets/              — Quick-add buttons, caffeine tracker
    settings/view/             — Settings (weight/activity/theme)
    history/view/              — History (7-day chart + records list)
  shared/
    theme/app_theme.dart       — Design system (colors/spacing/radii)
    models/                    — Data models
    services/                  — Preferences storage, weather API
    widgets/                   — Reusable widgets (progress ring)
```

## Installation

### Install APK directly
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Build from source
```bash
cd apps/hydrosmart
flutter pub get
flutter build apk --release
# APK output: build/app/outputs/flutter-apk/app-release.apk
```

## Quality Standards Met

- ✅ Value in 10 seconds (progress ring visible on launch)
- ✅ Core action in 3 taps (open → tap button → done)
- ✅ Dark / Light mode support
- ✅ 44×44pt minimum touch targets
- ✅ Animations 150-300ms with proper easing
- ✅ Offline-capable (core features work without network)

---

*v1.0.0 — 2026-02-16*
