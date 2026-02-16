import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/theme/app_theme.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(tableSettingsProvider);
    final guestCount = ref.watch(guestListProvider).length;

    return Scaffold(
      appBar: AppBar(title: const Text('桌位设置')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('桌数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: settings.tableCount > 1
                                  ? () => ref.read(tableSettingsProvider.notifier)
                                      .update(settings.copyWith(tableCount: settings.tableCount - 1))
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${settings.tableCount}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: () => ref.read(tableSettingsProvider.notifier)
                                  .update(settings.copyWith(tableCount: settings.tableCount + 1)),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('每桌人数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: settings.seatsPerTable > 2
                                  ? () => ref.read(tableSettingsProvider.notifier)
                                      .update(settings.copyWith(seatsPerTable: settings.seatsPerTable - 1))
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${settings.seatsPerTable}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            IconButton(
                              onPressed: () => ref.read(tableSettingsProvider.notifier)
                                  .update(settings.copyWith(seatsPerTable: settings.seatsPerTable + 1)),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _infoRow('宾客总数', '$guestCount 人'),
                    const SizedBox(height: AppSpacing.sm),
                    _infoRow('可用座位', '${settings.totalSeats} 个'),
                    const SizedBox(height: AppSpacing.sm),
                    _infoRow(
                      '座位状态',
                      guestCount <= settings.totalSeats
                          ? '✅ 座位充足'
                          : '⚠️ 座位不足 (差${guestCount - settings.totalSeats}个)',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
