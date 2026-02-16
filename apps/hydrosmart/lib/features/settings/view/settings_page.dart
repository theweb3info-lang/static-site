import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/services/preferences_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../home/view/home_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  final bool isOnboarding;
  const SettingsPage({super.key, this.isOnboarding = false});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late double _weight;
  late ActivityLevel _activity;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _weight = profile.weightKg;
    _activity = profile.activityLevel;
    _themeMode = ThemeMode.system;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    _themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOnboarding ? '欢迎使用 HydroSmart 💧' : '设置'),
        automaticallyImplyLeading: !widget.isOnboarding,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isOnboarding) ...[
                Text(
                  '让我们了解你，提供更精准的饮水建议',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Weight
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('体重', style: textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _weight,
                              min: 30,
                              max: 150,
                              divisions: 120,
                              label: '${_weight.toStringAsFixed(0)} kg',
                              onChanged: (v) => setState(() => _weight = v),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '${_weight.toStringAsFixed(0)} kg',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Activity level
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('活动水平', style: textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      ...ActivityLevel.values.map((level) => RadioListTile<ActivityLevel>(
                            title: Text(level.label),
                            subtitle: Text('×${level.multiplier.toStringAsFixed(1)}'),
                            value: level,
                            groupValue: _activity,
                            onChanged: (v) =>
                                setState(() => _activity = v!),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Theme
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('主题', style: textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.system, label: Text('跟随系统')),
                          ButtonSegment(value: ThemeMode.light, label: Text('浅色')),
                          ButtonSegment(value: ThemeMode.dark, label: Text('深色')),
                        ],
                        selected: {_themeMode},
                        onSelectionChanged: (v) {
                          ref.read(themeModeProvider.notifier).set(v.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Preview daily goal
              Center(
                child: Column(
                  children: [
                    Text(
                      '预估每日目标',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${UserProfile(weightKg: _weight, activityLevel: _activity).dailyGoalMl} ml',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(
                    widget.isOnboarding ? '开始使用 🚀' : '保存',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final profile = ref.read(userProfileProvider);
    await ref.read(userProfileProvider.notifier).update(
          profile.copyWith(weightKg: _weight, activityLevel: _activity),
        );
    if (mounted) {
      if (widget.isOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }
}
