import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../app/providers.dart';
import '../../../shared/theme/app_theme.dart';

class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  final GlobalKey _captureKey = GlobalKey();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(seatingPlanProvider);
    final guests = ref.watch(guestListProvider);
    final settings = ref.watch(tableSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('导出方案')),
      body: plan == null
          ? const Center(child: Text('请先生成座位方案', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                children: [
                  // Preview
                  RepaintBoundary(
                    key: _captureKey,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '💒 婚礼座位安排',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${guests.length}位宾客 · ${settings.tableCount}桌',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // Table list
                          ...List.generate(settings.tableCount, (i) {
                            final tableGuests = plan.tables[i] ?? [];
                            return Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              padding: const EdgeInsets.all(AppSpacing.base),
                              decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🪑 桌${i + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: tableGuests.map((gId) {
                                      final guest = guests.where((g) => g.id == gId).firstOrNull;
                                      return Chip(
                                        avatar: guest?.isVip == true
                                            ? const Text('⭐', style: TextStyle(fontSize: 12))
                                            : null,
                                        label: Text(guest?.name ?? '?'),
                                        backgroundColor: guest?.isVip == true
                                            ? AppColors.accent.withValues(alpha: 0.15)
                                            : AppColors.primary.withValues(alpha: 0.1),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Made with SeatPlan AI 💍',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Export buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportAsImage,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.image),
                      label: Text(_isExporting ? '导出中...' : '📷 导出为图片'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _shareAsText,
                      icon: const Icon(Icons.share),
                      label: const Text('📋 分享文字方案'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _exportAsImage() async {
    setState(() => _isExporting = true);
    try {
      final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/seatplan_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '婚礼座位安排方案 - SeatPlan AI',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _shareAsText() {
    final plan = ref.read(seatingPlanProvider);
    final guests = ref.read(guestListProvider);
    final settings = ref.read(tableSettingsProvider);
    if (plan == null) return;

    final buffer = StringBuffer();
    buffer.writeln('💒 婚礼座位安排方案');
    buffer.writeln('${'=' * 20}');
    buffer.writeln('宾客: ${guests.length}人 | 桌数: ${settings.tableCount}');
    buffer.writeln();

    for (int i = 0; i < settings.tableCount; i++) {
      final tableGuests = plan.tables[i] ?? [];
      buffer.writeln('🪑 桌${i + 1}:');
      for (final gId in tableGuests) {
        final guest = guests.where((g) => g.id == gId).firstOrNull;
        buffer.writeln('  ${guest?.isVip == true ? "⭐" : "•"} ${guest?.name ?? "?"}');
      }
      buffer.writeln();
    }
    buffer.writeln('Made with SeatPlan AI 💍');

    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }
}
