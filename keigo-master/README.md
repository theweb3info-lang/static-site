# 敬語マスター (KeigoMaster)

AIを活用した日本語敬語変換アプリ。カジュアルな日本語を入力すると、選択した敬語レベルに自動変換します。

## Features

- **4つの変換モード**: 丁寧語・尊敬語・謙譲語・ビジネスメール
- **GPT-4o-mini**: OpenAI APIによる高精度な敬語変換
- **変換履歴**: 過去の変換を保存・参照
- **コピー機能**: ワンタップで変換結果をコピー
- **ダークテーマ**: 目に優しいUI、Noto Sans JPフォント

## How to Run

```bash
cd keigo-master
flutter pub get
flutter run
```

初回起動時にOpenAI APIキーの入力が求められます。

## Architecture

```
lib/
├── main.dart                    # App entry, theme, onboarding
├── app/router.dart              # GoRouter navigation
├── features/
│   ├── convert/                 # Main conversion screen + controller
│   ├── history/                 # Conversion history
│   └── settings/                # API key & preferences
├── services/
│   ├── ai_service.dart          # OpenAI API integration
│   └── storage_service.dart     # SharedPreferences wrapper
├── models/conversion.dart       # Data model
└── utils/
    ├── constants.dart           # App constants
    └── keigo_prompts.dart       # System prompts per keigo level
```

**State Management**: flutter_riverpod  
**Navigation**: go_router  
**Storage**: shared_preferences  
**API**: http + OpenAI Chat Completions

## Monetization Plan

| Tier | Price | Limits |
|------|-------|--------|
| Free | ¥0 | 5 conversions/day |
| Pro | ¥480/month | Unlimited conversions |

Revenue model: subscription via App Store / Google Play in-app purchases.

## TODO (MVP)

- [ ] RevenueCat integration for Pro subscriptions
- [ ] Streaming API response (real-time output)
- [ ] Offline mode with on-device model
- [ ] Share button (LINE, Twitter, etc.)
- [ ] Widget for quick conversion
- [ ] iPad / tablet layout
- [ ] Explanation mode (why this keigo was chosen)
- [ ] Reverse conversion (keigo → casual)
- [ ] Unit & widget tests
- [ ] App Store / Play Store listing assets
