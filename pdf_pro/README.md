# PDF Pro

**Merge · Split · Rearrange** — A beautiful, native macOS PDF tool.

![macOS 13.0+](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

## Features

### 🔗 Merge
Drag & drop multiple PDF files, reorder freely, and combine into one with progress feedback.

### ✂️ Split
Three modes: page range, every N pages, or extract specific pages (`1, 3, 5-8`). Side-by-side preview.

### 📄 Rearrange
Visual thumbnail grid. Drag to reorder, click to select, right-click to rotate or delete pages.

## Design

- Modern macOS-native UI with hidden title bar
- Blue-purple brand gradient (#667EEA → #764BA2)
- Smooth hover animations and spring physics
- Full dark mode support
- Drop zone visual guides
- Glass material and subtle shadows

## Tech Stack

- **Swift + SwiftUI** — native macOS experience
- **PDFKit** — Apple's built-in PDF framework
- **macOS 13.0+** (Ventura and later)
- Zero third-party dependencies
- App Sandbox enabled

## Build

```bash
# With XcodeGen installed:
xcodegen generate
open PDFPro.xcodeproj

# Or just open the .xcodeproj and build (⌘B)
```

## Localization

- English (primary)
- Simplified Chinese (简体中文)

## Privacy

PDF Pro processes everything locally. No data collection, no analytics, no network requests. See [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

## License

MIT
