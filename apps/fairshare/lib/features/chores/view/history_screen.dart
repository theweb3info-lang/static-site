import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../app/providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(choreLogsProvider((from: null, to: null)));

    return Scaffold(
      appBar: AppBar(title: const Text('完成记录 📋')),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📝', style: TextStyle(fontSize: 64)),
                  SizedBox(height: AppSpacing.base),
                  Text('还没有记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: AppSpacing.sm),
                  Text('去完成一些家务吧！', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: logs.length,
            itemBuilder: (ctx, i) {
              final log = logs[i];
              final color = AppColors.avatarColors[(log.memberAvatarColor ?? 0) % AppColors.avatarColors.length];
              final timeStr = DateFormat('MM/dd HH:mm').format(log.completedAt);

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.xs),
                  leading: CircleAvatar(
                    backgroundColor: color,
                    child: Text(
                      log.memberName?[0] ?? '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(log.memberName ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Text(' 完成了 ', style: TextStyle(color: AppColors.textSecondary)),
                      Text('${log.choreEmoji ?? ''} ${log.choreName ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  subtitle: Text(timeStr, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '+${log.points}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('出错了 😅\n$e')),
      ),
    );
  }
}
