import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/preferences_service.dart';
import '../../../shared/services/weather_service.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/theme/app_theme.dart';
import '../../settings/view/settings_page.dart';
import '../../history/view/history_page.dart';
import '../widgets/quick_add_button.dart';
import '../widgets/caffeine_tracker.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;
  double _lastProgress = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final temp = await WeatherService.fetchTemperature();
    if (mounted && temp != null) {
      ref.read(weatherTempProvider.notifier).state = temp;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intake = ref.watch(todayIntakeProvider);
    final goal = ref.watch(adjustedGoalProvider);
    final weather = ref.watch(weatherTempProvider);
    final progress = goal > 0 ? intake / goal : 0.0;

    // Animate progress changes
    if (progress != _lastProgress) {
      _progressAnim = Tween<double>(begin: _lastProgress, end: progress).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0);
      _lastProgress = progress;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HydroSmart 💧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: '历史记录',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: '设置',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Weather info
              if (weather != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            weather > 30
                                ? Icons.wb_sunny_rounded
                                : weather > 20
                                    ? Icons.cloud_rounded
                                    : Icons.ac_unit_rounded,
                            color: weather > 30
                                ? AppColors.warning
                                : colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${weather.toStringAsFixed(0)}°C',
                            style: textTheme.bodyMedium,
                          ),
                          if (weather > 30) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '天热多喝水 🔥',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),

              // Progress ring
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, child) {
                  return ProgressRing(
                    progress: _progressAnim.value,
                    size: 220,
                    strokeWidth: 16,
                    color: progress >= 1.0
                        ? AppColors.success
                        : colorScheme.primary,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${intake}ml',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '目标 ${goal}ml',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).clamp(0, 999).toStringAsFixed(0)}%',
                          style: textTheme.titleMedium?.copyWith(
                            color: progress >= 1.0
                                ? AppColors.success
                                : colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (progress >= 1.0)
                          const Text('🎉 达标!', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick add buttons
              Text('快速记录', style: textTheme.titleSmall),
              const SizedBox(height: AppSpacing.md),
              const Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                alignment: WrapAlignment.center,
                children: [
                  QuickAddButton(amountMl: 150, icon: Icons.local_cafe_rounded, label: '小杯'),
                  QuickAddButton(amountMl: 250, icon: Icons.water_drop_rounded, label: '一杯'),
                  QuickAddButton(amountMl: 500, icon: Icons.water_rounded, label: '大杯'),
                  QuickAddButton(amountMl: 750, icon: Icons.sports_bar_rounded, label: '水瓶'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Caffeine tracker
              const CaffeineTracker(),
            ],
          ),
        ),
      ),
    );
  }
}
