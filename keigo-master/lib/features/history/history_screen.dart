import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/storage_service.dart';
import '../../models/conversion.dart';

final historyProvider = Provider<List<Conversion>>((ref) {
  return ref.watch(storageServiceProvider).getHistory();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('変換履歴'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('履歴を削除'),
                    content: const Text('すべての変換履歴を削除しますか？'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('削除')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(storageServiceProvider).clearHistory();
                  ref.invalidate(historyProvider);
                }
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('変換履歴がありません'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(label: Text(item.level.label)),
                            const Spacer(),
                            Text(
                              '${item.timestamp.month}/${item.timestamp.day} ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item.input,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                )),
                        const Divider(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(item.output, style: Theme.of(context).textTheme.bodyMedium),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: item.output));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('コピーしました'), duration: Duration(seconds: 1)),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
