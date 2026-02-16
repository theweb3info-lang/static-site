import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../features/scan/scan_controller.dart';
import '../../models/scan_result.dart';

final historyProvider = Provider<List<ScanResult>>((ref) {
  try {
    final storage = ref.watch(storageProvider);
    return storage.loadHistory();
  } catch (_) {
    return [];
  }
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan History')),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No scans yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text('Your scan history will appear here',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final scan = history[index];
                final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(scan.timestamp);

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scan.safe ? Colors.green.shade50 : Colors.red.shade50,
                      child: Text(scan.safe ? '🟢' : '🔴', style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(
                      scan.safe
                          ? 'Safe ✓'
                          : '${scan.foundAllergens.length} allergen(s) found',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: scan.safe ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    subtitle: Text(
                      '$dateStr\n${scan.extractedText.length > 60 ? '${scan.extractedText.substring(0, 60)}...' : scan.extractedText}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
