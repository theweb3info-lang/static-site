# 🏠 FairShare - Fair Chore Distribution

> Making every contribution visible ✨

## Overview

FairShare is a chore-tracking app for couples and roommates. It gamifies housework with points and visualizes "who does more" — solving invisible labor disputes once and for all.

## Features

### 1. 🏡 Create a Household
- Create a household group with auto-generated 6-digit invite code
- Share the code with family/roommates to join

### 2. 📋 Chore Templates
- 15 built-in chore templates (dishes, mopping, cooking, etc.)
- Each chore has an emoji icon and point value (1-5)
- Add custom chores anytime

### 3. ✅ One-Tap Check-in
- Tap a chore to mark it complete
- Multi-member picker when household has multiple people
- Confetti celebration animation on completion 🎉

### 4. 📊 Fairness Dashboard
- Pie chart showing each person's contribution
- Fairness score (0-100%)
- Friendly messages: "Everyone's doing great!" / "Could use some help~"
- Filter by this week / this month / all time

### 5. 📝 History Log
- Chronological record of all completed chores
- Shows who did what and points earned

### 6. 👨‍👩‍👧‍👦 Member Management
- View all household members
- Add new members with color avatars
- Copy invite code with one tap

## Tech Stack

- **Flutter 3.38** + **Dart 3.10**
- **Riverpod** for state management
- **sqflite** for local storage
- **fl_chart** for data visualization
- **confetti** for celebration animations

## Build

```bash
flutter pub get
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Design Philosophy

- 🎨 Vibrant colors: Purple primary + pink accent, warm but not childish
- 💬 Friendly tone: Never confrontational, encourages cooperation
- ⚡ Zero learning curve: Open and use immediately
- 🌙 Light/dark mode auto-adaptive
