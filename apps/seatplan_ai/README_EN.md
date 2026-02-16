# 💒 SeatPlan AI - Wedding Seating Optimizer

AI-powered wedding seating arrangement tool. Input guest relationships and constraints, get an optimized seating plan instantly.

## ✨ Features

1. **Guest Management** - Add guests with name and tags (family/friend/colleague/VIP)
2. **Constraint Setup** - Must sit together, must not sit together, VIP front rows
3. **Table Configuration** - Customize number of tables and seats per table
4. **AI Optimization** - One-tap simulated annealing + greedy algorithm for optimal seating
5. **Visual Seating Chart** - Round table top-down view with drag-and-drop adjustment
6. **Export & Share** - Export as image or text, share with one tap

## 🧠 Algorithm

Two-phase optimization:
- **Phase 1: Greedy Assignment** - Prioritizes VIPs and heavily-constrained guests
- **Phase 2: Simulated Annealing** - 2000 iterations, random swaps with cooling schedule

Scoring dimensions:
- Hard constraint satisfaction (must-together / must-apart)
- VIP front-row priority
- Table balance
- Same-tag clustering bonus

## 🛠 Tech Stack

- Flutter 3.38+
- Riverpod state management
- CustomPainter for seating visualization
- Simulated annealing optimization
- share_plus for sharing

## 📦 Build

```bash
flutter pub get
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`
