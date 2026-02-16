import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scan_controller.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  final String imagePath;
  const ScanResultScreen({super.key, required this.imagePath});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scanControllerProvider.notifier).scanImage(widget.imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Results')),
      body: scanState.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text('Analyzing ingredients...', style: TextStyle(fontSize: 16, color: Colors.grey)),
              SizedBox(height: 8),
              Text('🔍 Reading text → 🤖 AI analysis', style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                Text(e.toString(), textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
        data: (result) {
          if (result == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final statusColor = result.safe ? Colors.green : Colors.red;
          final statusEmoji = result.safe ? '🟢' : '🔴';
          final statusText = result.safe ? 'SAFE' : 'DANGER';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  children: [
                    Text(statusEmoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(statusText,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: statusColor)),
                    if (!result.safe)
                      Text('${result.foundAllergens.length} allergen(s) detected',
                          style: TextStyle(fontSize: 14, color: statusColor)),
                  ],
                ),
              ),

              // Found allergens
              if (result.foundAllergens.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('⚠️ Found Allergens',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...result.foundAllergens.map((a) => Card(
                      color: Colors.red.shade50,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: a.confidence == 'high'
                              ? Colors.red
                              : a.confidence == 'medium'
                                  ? Colors.orange
                                  : Colors.yellow.shade700,
                          child: Text(
                            a.confidence == 'high' ? '🔴' : a.confidence == 'medium' ? '🟡' : '🟡',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Found: "${a.sourceIngredient}" → ${a.allergenCategory}\nConfidence: ${a.confidence}',
                        ),
                        isThreeLine: true,
                      ),
                    )),
              ],

              // Warnings
              if (result.warnings.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('⚡ Warnings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...result.warnings.map((w) => Card(
                      color: Colors.amber.shade50,
                      child: ListTile(
                        leading: const Text('🟡', style: TextStyle(fontSize: 20)),
                        title: Text(w),
                      ),
                    )),
              ],

              // Extracted text
              const SizedBox(height: 24),
              ExpansionTile(
                title: const Text('📝 Extracted Text'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(result.extractedText,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  ),
                ],
              ),

              // Image preview
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(widget.imagePath), height: 200, fit: BoxFit.cover),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Scan Another'),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
