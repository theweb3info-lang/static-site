import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Settings'),
        titleWidth: 150,
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TimerSettingsSection(),
                  SizedBox(height: 32),
                  _BehaviorSettingsSection(),
                  SizedBox(height: 32),
                  _AppearanceSettingsSection(),
                  SizedBox(height: 32),
                  _GoalsSettingsSection(),
                  SizedBox(height: 32),
                  _AboutSection(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: MacosTheme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: MacosTheme.of(context).dividerColor,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget trailing;
  final bool showDivider;

  const _SettingsRow({
    required this.title,
    this.subtitle,
    required this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: MacosTheme.of(context).dividerColor,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: MacosTheme.of(context).typography.caption1.color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _TimerSettingsSection extends StatelessWidget {
  const _TimerSettingsSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return _SettingsSection(
      title: 'Timer',
      children: [
        _SettingsRow(
          title: 'Focus Duration',
          subtitle: '${settings.focusDuration} minutes',
          trailing: _DurationPicker(
            value: settings.focusDuration,
            min: 1,
            max: 120,
            onChanged: settings.setFocusDuration,
          ),
        ),
        _SettingsRow(
          title: 'Short Break',
          subtitle: '${settings.shortBreakDuration} minutes',
          trailing: _DurationPicker(
            value: settings.shortBreakDuration,
            min: 1,
            max: 30,
            onChanged: settings.setShortBreakDuration,
          ),
        ),
        _SettingsRow(
          title: 'Long Break',
          subtitle: '${settings.longBreakDuration} minutes',
          trailing: _DurationPicker(
            value: settings.longBreakDuration,
            min: 1,
            max: 60,
            onChanged: settings.setLongBreakDuration,
          ),
        ),
        _SettingsRow(
          title: 'Long Break After',
          subtitle: 'Every ${settings.pomodorosUntilLongBreak} pomodoros',
          trailing: _DurationPicker(
            value: settings.pomodorosUntilLongBreak,
            min: 2,
            max: 10,
            onChanged: settings.setPomodorosUntilLongBreak,
          ),
          showDivider: false,
        ),
      ],
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _DurationPicker({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MacosIconButton(
          icon: const MacosIcon(CupertinoIcons.minus_circle, size: 20),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        MacosIconButton(
          icon: const MacosIcon(CupertinoIcons.plus_circle, size: 20),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _BehaviorSettingsSection extends StatelessWidget {
  const _BehaviorSettingsSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return _SettingsSection(
      title: 'Behavior',
      children: [
        _SettingsRow(
          title: 'Auto-start Breaks',
          subtitle: 'Automatically start breaks after focus',
          trailing: MacosSwitch(
            value: settings.autoStartBreaks,
            onChanged: (value) => settings.setAutoStartBreaks(value),
          ),
        ),
        _SettingsRow(
          title: 'Auto-start Pomodoros',
          subtitle: 'Automatically start next focus after break',
          trailing: MacosSwitch(
            value: settings.autoStartPomodoros,
            onChanged: (value) => settings.setAutoStartPomodoros(value),
          ),
        ),
        _SettingsRow(
          title: 'Sound Effects',
          subtitle: 'Play sound when timer completes',
          trailing: MacosSwitch(
            value: settings.soundEnabled,
            onChanged: (value) => settings.setSoundEnabled(value),
          ),
        ),
        _SettingsRow(
          title: 'Notifications',
          subtitle: 'Show system notifications',
          trailing: MacosSwitch(
            value: settings.notificationsEnabled,
            onChanged: (value) => settings.setNotificationsEnabled(value),
          ),
        ),
        _SettingsRow(
          title: 'Lock Screen on Break',
          subtitle: 'Lock screen when focus session ends',
          trailing: MacosSwitch(
            value: settings.lockScreenOnBreak,
            onChanged: (value) => settings.setLockScreenOnBreak(value),
          ),
          showDivider: false,
        ),
      ],
    );
  }
}

class _AppearanceSettingsSection extends StatelessWidget {
  const _AppearanceSettingsSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return _SettingsSection(
      title: 'Appearance',
      children: [
        _SettingsRow(
          title: 'Theme',
          trailing: MacosPopupButton<ThemeMode>(
            value: settings.themeMode,
            items: const [
              MacosPopupMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
              MacosPopupMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              MacosPopupMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                settings.setThemeMode(value);
              }
            },
          ),
        ),
        _SettingsRow(
          title: 'Show in Menu Bar',
          subtitle: 'Display timer in system menu bar',
          trailing: MacosSwitch(
            value: settings.showInMenuBar,
            onChanged: (value) => settings.setShowInMenuBar(value),
          ),
          showDivider: false,
        ),
      ],
    );
  }
}

class _GoalsSettingsSection extends StatelessWidget {
  const _GoalsSettingsSection();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return _SettingsSection(
      title: 'Goals',
      children: [
        _SettingsRow(
          title: 'Daily Pomodoro Goal',
          subtitle: '${settings.dailyPomodoroGoal} pomodoros per day',
          trailing: _DurationPicker(
            value: settings.dailyPomodoroGoal,
            min: 1,
            max: 20,
            onChanged: settings.setDailyPomodoroGoal,
          ),
          showDivider: false,
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'About',
      children: [
        _SettingsRow(
          title: 'Pomodoro Timer',
          subtitle: 'Version 1.0.0',
          trailing: const Text('🍅'),
        ),
        _SettingsRow(
          title: 'Built with',
          trailing: const Text('Flutter ❤️'),
          showDivider: false,
        ),
      ],
    );
  }
}
