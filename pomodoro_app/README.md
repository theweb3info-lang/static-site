# 🍅 Pomodoro Timer for macOS

A top-tier Pomodoro Timer application built with Flutter, featuring native macOS integration including lock screen functionality.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)

## ✨ Features

### Core Timer
- **Standard Pomodoro Timer**: 25 minutes focus + 5 minutes break
- **Customizable Durations**: Adjust focus, short break, and long break times
- **Long Break Cycle**: Automatic long break after completing 4 pomodoros
- **Session Types**: Focus, Short Break, Long Break modes
- **Quick Controls**: Add/subtract minutes, skip sessions

### Task Management
- **Task List**: Create and manage tasks with titles and descriptions
- **Priority Levels**: High, Medium, Low priority indicators
- **Pomodoro Estimation**: Set estimated pomodoros per task
- **Progress Tracking**: Track completed pomodoros per task
- **Task Selection**: Link current timer session to a specific task

### Statistics & Analytics
- **Daily Progress**: Track today's completed pomodoros and focus time
- **Weekly/Monthly Charts**: Visual charts for pomodoros and focus time
- **Streak Tracking**: Current streak and longest streak
- **Goal Progress**: Daily pomodoro goal with progress indicator

### macOS Integration
- **Menu Bar Timer**: Shows current timer in system menu bar
- **Native Notifications**: System notifications when sessions complete
- **🔒 Lock Screen on Break**: Automatically locks screen when focus ends (enforces break!)
- **macOS UI**: Native macOS design using macos_ui package

### Customization
- **Theme Support**: Light, Dark, and System theme modes
- **Auto-start Options**: Auto-start breaks and/or pomodoros
- **Sound Effects**: Notification sounds
- **Daily Goals**: Set your daily pomodoro target

## 🚀 Getting Started

### Prerequisites
- macOS 11.0 or later
- Flutter SDK 3.0+
- Xcode 14+

### Installation

1. Clone the repository:
```bash
cd /Users/andy_crab/.openclaw/workspace/pomodoro_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run -d macos
```

### Building for Release

```bash
flutter build macos --release
```

The built app will be in `build/macos/Build/Products/Release/`.

## 🔐 Lock Screen Feature

The app includes a **lock screen feature** that activates when your focus session ends. This helps enforce breaks and prevent you from immediately returning to work.

### How it works:
1. When a focus session completes, the app sends a notification
2. If "Lock Screen on Break" is enabled in settings, the screen will be locked
3. You'll need to unlock your Mac to continue, giving you a natural break

### Technical Implementation:
The lock screen uses macOS native APIs through Flutter's MethodChannel:
- `pmset displaysleepnow` - Puts display to sleep
- `CGSession -suspend` - Locks the screen

> ⚠️ **Note**: The app runs without App Sandbox to enable lock screen functionality. This is required for executing system commands.

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── task.dart
│   ├── pomodoro_session.dart
│   └── daily_statistics.dart
├── providers/                # State management
│   ├── timer_provider.dart
│   ├── task_provider.dart
│   ├── settings_provider.dart
│   └── statistics_provider.dart
├── screens/                  # UI screens
│   ├── main_screen.dart
│   ├── timer_screen.dart
│   ├── tasks_screen.dart
│   ├── statistics_screen.dart
│   └── settings_screen.dart
├── services/                 # Business logic
│   ├── database_service.dart
│   ├── notification_service.dart
│   ├── platform_service.dart
│   └── tray_service.dart
└── widgets/                  # Reusable widgets
```

## 🛠 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `macos_ui` | Native macOS UI components |
| `window_manager` | Window control |
| `tray_manager` | Menu bar integration |
| `sqflite` | Local database |
| `shared_preferences` | Settings storage |
| `flutter_local_notifications` | System notifications |
| `fl_chart` | Statistics charts |
| `intl` | Date formatting |

## 🎨 Design Philosophy

This app follows these design principles:
- **Native Feel**: Uses macOS design language and conventions
- **Simplicity**: Clean interface without unnecessary complexity
- **Effectiveness**: Focus on what matters - helping you stay productive
- **Privacy**: All data stored locally, no cloud sync required

## 📝 Usage Tips

1. **Start Simple**: Use default 25/5 minute cycles first
2. **Link Tasks**: Connect your timer to tasks for better tracking
3. **Enable Lock Screen**: For maximum focus enforcement
4. **Check Statistics**: Review your patterns weekly
5. **Adjust as Needed**: Fine-tune durations based on your workflow

## 🔧 Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Space` | Start/Pause timer |
| `R` | Reset timer |
| `S` | Skip to next session |

## 📊 Comparable Apps

This app aims to match features from top Pomodoro apps:
- **Flow** - Beautiful design, focus on simplicity
- **Be Focused Pro** - Task integration, statistics
- **Session** - Goals, insights, beautiful charts
- **Focus To-Do** - Task management, reports

## 🤝 Contributing

Feel free to submit issues and pull requests!

## 📄 License

MIT License - feel free to use and modify as needed.

---

Made with ❤️ and 🍅 using Flutter
