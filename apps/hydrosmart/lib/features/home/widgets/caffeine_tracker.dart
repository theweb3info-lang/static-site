import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/preferences_service.dart';
import '../../../shared/theme/app_theme.dart';

class CaffeineTracker extends ConsumerWidget {
  const CaffeineTracker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.coffee_rounded, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('今日咖啡因', style: textTheme.titleSmall),
                const Spacer(),
                Text(
                  '${profile.caffeineCount} 杯',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundButton(
                  icon: Icons.remove,
                  onTap: profile.caffeineCount > 0
                      ? () => ref.read(userProfileProvider.notifier).update(
                            profile.copyWith(caffeineCount: profile.caffeineCount - 1),
                          )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    '☕ × ${profile.caffeineCount}',
                    style: textTheme.titleLarge,
                  ),
                ),
                _RoundButton(
                  icon: Icons.add,
                  onTap: () => ref.read(userProfileProvider.notifier).update(
                        profile.copyWith(caffeineCount: profile.caffeineCount + 1),
                      ),
                ),
              ],
            ),
            if (profile.caffeineCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  '每杯咖啡需额外补充 ~150ml 水',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: onTap != null
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
