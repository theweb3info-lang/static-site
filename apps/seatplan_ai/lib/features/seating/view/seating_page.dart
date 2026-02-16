import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/table_painter.dart';

class SeatingPage extends ConsumerStatefulWidget {
  const SeatingPage({super.key});

  @override
  ConsumerState<SeatingPage> createState() => _SeatingPageState();
}

class _SeatingPageState extends ConsumerState<SeatingPage> with SingleTickerProviderStateMixin {
  String? _dragGuestId;
  int? _dragFromTable;
  Offset? _dragPosition;
  int? _highlightTable;
  bool _isOptimizing = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(seatingPlanProvider);
    final guests = ref.watch(guestListProvider);
    final settings = ref.watch(tableSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('座位方案'),
        actions: [
          if (plan != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: Icon(
                  plan.violationCount == 0 ? Icons.check_circle : Icons.warning,
                  size: 18,
                  color: plan.violationCount == 0 ? AppColors.success : AppColors.warning,
                ),
                label: Text(
                  plan.violationCount == 0 ? '完美方案' : '${plan.violationCount}个冲突',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Optimize button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: guests.isEmpty
                    ? null
                    : () async {
                        setState(() => _isOptimizing = true);
                        _pulseController.repeat(reverse: true);
                        // Small delay to show animation
                        await Future.delayed(const Duration(milliseconds: 500));
                        ref.read(optimizeProvider)();
                        _pulseController.stop();
                        setState(() => _isOptimizing = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 座位安排优化完成！'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                icon: _isOptimizing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_fix_high),
                label: Text(_isOptimizing ? 'AI优化中...' : '🪄 一键AI优化排座'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Seating chart
          Expanded(
            child: plan == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.table_restaurant, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          guests.isEmpty ? '请先添加宾客' : '点击上方按钮开始优化',
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(constraints.maxWidth, constraints.maxHeight);
                      final layouts = calculateTableLayouts(
                        size: size,
                        tableCount: settings.tableCount,
                        seatsPerTable: settings.seatsPerTable,
                        tableAssignments: plan.tables,
                        guests: guests,
                      );

                      return GestureDetector(
                        onPanStart: (details) => _onDragStart(details, layouts),
                        onPanUpdate: (details) => _onDragUpdate(details, layouts),
                        onPanEnd: (details) => _onDragEnd(layouts),
                        child: Stack(
                          children: [
                            CustomPaint(
                              size: size,
                              painter: SeatingChartPainter(
                                tables: layouts,
                                highlightGuestId: _dragGuestId,
                                highlightTableIndex: _highlightTable,
                              ),
                            ),
                            // Drag indicator
                            if (_dragPosition != null && _dragGuestId != null)
                              Positioned(
                                left: _dragPosition!.dx - 22,
                                top: _dragPosition!.dy - 22,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getGuestInitial(_dragGuestId!),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Legend
          if (plan != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem(AppColors.primary, '普通宾客'),
                  const SizedBox(width: AppSpacing.base),
                  _legendItem(AppColors.accent, 'VIP宾客'),
                  const SizedBox(width: AppSpacing.base),
                  _legendItem(AppColors.border.withValues(alpha: 0.5), '空座位'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  String _getGuestInitial(String guestId) {
    final guests = ref.read(guestListProvider);
    final guest = guests.where((g) => g.id == guestId).firstOrNull;
    return guest?.name.isNotEmpty == true ? guest!.name[0] : '?';
  }

  void _onDragStart(DragStartDetails details, List<TableLayout> layouts) {
    final pos = details.localPosition;
    for (final table in layouts) {
      for (final seat in table.seats) {
        if ((seat.position - pos).distance < 22 && seat.guestId != null) {
          setState(() {
            _dragGuestId = seat.guestId;
            _dragFromTable = seat.tableIndex;
            _dragPosition = pos;
          });
          return;
        }
      }
    }
  }

  void _onDragUpdate(DragUpdateDetails details, List<TableLayout> layouts) {
    if (_dragGuestId == null) return;
    final pos = details.localPosition;
    int? nearTable;
    for (final table in layouts) {
      if ((table.center - pos).distance < table.radius + 40) {
        nearTable = table.tableIndex;
        break;
      }
    }
    setState(() {
      _dragPosition = pos;
      _highlightTable = nearTable;
    });
  }

  void _onDragEnd(List<TableLayout> layouts) {
    if (_dragGuestId != null && _highlightTable != null && _dragFromTable != null && _highlightTable != _dragFromTable) {
      final plan = ref.read(seatingPlanProvider);
      if (plan != null) {
        final settings = ref.read(tableSettingsProvider);
        final targetGuests = plan.tables[_highlightTable] ?? [];
        if (targetGuests.length < settings.seatsPerTable) {
          final newPlan = plan.moveGuest(_dragGuestId!, _dragFromTable!, _highlightTable!);
          ref.read(seatingPlanProvider.notifier).set(newPlan);
        }
      }
    }
    setState(() {
      _dragGuestId = null;
      _dragFromTable = null;
      _dragPosition = null;
      _highlightTable = null;
    });
  }
}
