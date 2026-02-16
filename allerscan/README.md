# 🔍 AllerScan

**AI-powered allergen scanner** — snap a photo of any ingredient list and instantly know if it's safe for you.

## Overview

AllerScan uses OCR (Google ML Kit) + AI (GPT-4o-mini) to detect allergens in food product labels, including hidden allergens like casein (milk), lecithin (soy), and albumin (egg).

### How It Works
1. 📸 **Scan** — Point camera at ingredient list or pick from gallery
2. 🔍 **OCR** — Text extracted via Google ML Kit
3. 🤖 **AI Analysis** — GPT-4o-mini identifies allergens including hidden forms
4. ✅ **Results** — Color-coded: 🟢 SAFE / 🟡 CAUTION / 🔴 DANGER

## Getting Started

```bash
cd allerscan
flutter pub get
flutter run
```

> **Note:** Camera features require a physical device (not simulator).

### Setup
1. Set your OpenAI API key in **Settings**
2. Select your allergens in **Profile**
3. Start scanning!

## Architecture

```
lib/
├── main.dart                    # App entry + theme
├── app/router.dart              # GoRouter navigation
├── features/
│   ├── scan/                    # Camera, OCR, results
│   ├── profile/                 # Allergen profile setup
│   ├── history/                 # Scan history
│   └── settings/                # API key, preferences
├── services/
│   ├── ocr_service.dart         # Google ML Kit wrapper
│   ├── ai_service.dart          # OpenAI GPT-4o-mini
│   └── storage_service.dart     # SharedPreferences
├── models/                      # Data models
└── utils/                       # Constants, prompts, allergen DB
```

**State Management:** Riverpod  
**Navigation:** GoRouter  
**Storage:** SharedPreferences (local)

## Monetization

| Feature | Free | Pro ($4.99/mo) |
|---------|------|----------------|
| Daily scans | 3 | Unlimited |
| Allergen profile | ✅ | ✅ |
| Scan history | Last 5 | Unlimited |
| Family profiles | — | ✅ |
| Priority support | — | ✅ |

## TODO — MVP Completion

- [ ] Implement in-app purchase (RevenueCat)
- [ ] Add onboarding flow
- [ ] Offline mode with local allergen DB fallback
- [ ] Multi-language OCR support
- [ ] Barcode scanning (Open Food Facts API)
- [ ] Family profiles (multiple allergen sets)
- [ ] Push notifications for product recalls
- [ ] Widget for quick scan from home screen
- [ ] Analytics (Firebase/PostHog)
- [ ] App Store & Play Store listings
