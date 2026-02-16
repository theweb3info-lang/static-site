import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/constraint.dart';
import '../../guests/model/guest.dart';
import '../../../app/providers.dart';
import '../../../shared/theme/app_theme.dart';

class ConstraintPage extends ConsumerWidget {
  const ConstraintPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constraints = ref.watch(constraintListProvider);
    final guests = ref.watch(guestListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('约束设置')),
      body: constraints.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.link_off, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: AppSpacing.base),
                  Text('还没有约束', style: TextStyle(fontSize: 18, color: AppColors.textSecondary.withValues(alpha: 0.6))),
                  const SizedBox(height: AppSpacing.sm),
                  Text('设置谁必须同桌、谁不能同桌', style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withValues(alpha: 0.4))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.base),
              itemCount: constraints.length,
              itemBuilder: (context, index) {
                final c = constraints[index];
                final g1 = guests.where((g) => g.id == c.guestId1).firstOrNull;
                final g2 = c.guestId2 != null ? guests.where((g) => g.id == c.guestId2).firstOrNull : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Card(
                    child: ListTile(
                      leading: Text(SeatConstraint.typeIcon(c.type), style: const TextStyle(fontSize: 24)),
                      title: Text(
                        c.type == ConstraintType.vipFront
                            ? '${g1?.name ?? "?"} VIP靠前'
                            : '${g1?.name ?? "?"} ↔ ${g2?.name ?? "?"}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(SeatConstraint.typeLabel(c.type)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => ref.read(constraintListProvider.notifier).remove(c.id),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: guests.length < 2
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请先添加至少2位宾客')),
                )
            : () => _showAddConstraintDialog(context, ref, guests),
        child: const Icon(Icons.add_link),
      ),
    );
  }

  void _showAddConstraintDialog(BuildContext context, WidgetRef ref, List<Guest> guests) {
    var type = ConstraintType.mustTogether;
    String? guest1Id;
    String? guest2Id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('添加约束', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.base),
              Wrap(
                spacing: 8,
                children: ConstraintType.values.map((t) {
                  return ChoiceChip(
                    label: Text('${SeatConstraint.typeIcon(t)} ${SeatConstraint.typeLabel(t)}'),
                    selected: type == t,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (_) => setState(() => type = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.base),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '宾客1'),
                items: guests.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                onChanged: (v) => setState(() => guest1Id = v),
              ),
              if (type != ConstraintType.vipFront) ...[
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: '宾客2'),
                  items: guests.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                  onChanged: (v) => setState(() => guest2Id = v),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (guest1Id == null) return;
                    if (type != ConstraintType.vipFront && guest2Id == null) return;
                    if (guest1Id == guest2Id) return;
                    ref.read(constraintListProvider.notifier).add(SeatConstraint(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      type: type,
                      guestId1: guest1Id!,
                      guestId2: type != ConstraintType.vipFront ? guest2Id : null,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('添加约束'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
