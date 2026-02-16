import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/guest.dart';
import '../../../app/providers.dart';
import '../../../shared/theme/app_theme.dart';

class GuestListPage extends ConsumerWidget {
  const GuestListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guests = ref.watch(guestListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('宾客管理')),
      body: guests.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: AppSpacing.base),
                  Text('还没有宾客', style: TextStyle(fontSize: 18, color: AppColors.textSecondary.withValues(alpha: 0.6))),
                  const SizedBox(height: AppSpacing.sm),
                  Text('点击右下角 + 添加宾客', style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withValues(alpha: 0.4))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.base),
              itemCount: guests.length,
              itemBuilder: (context, index) {
                final guest = guests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: guest.isVip ? AppColors.accent : AppColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          guest.name.isNotEmpty ? guest.name[0] : '?',
                          style: TextStyle(
                            color: guest.isVip ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(guest.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(Guest.tagLabel(guest.tag), style: const TextStyle(fontSize: 12)),
                          ),
                          if (guest.isVip) ...[
                            const SizedBox(width: 8),
                            const Text('⭐ VIP', style: TextStyle(fontSize: 12)),
                          ],
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => ref.read(guestListProvider.notifier).remove(guest.id),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGuestDialog(context, ref),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddGuestDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    var selectedTag = GuestTag.friend;
    var isVip = false;

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
              const Text('添加宾客', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.base),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '姓名',
                  hintText: '请输入宾客姓名',
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Wrap(
                spacing: 8,
                children: GuestTag.values.map((tag) {
                  final selected = tag == selectedTag;
                  return ChoiceChip(
                    label: Text(Guest.tagLabel(tag)),
                    selected: selected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (_) => setState(() => selectedTag = tag),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                title: const Text('VIP宾客'),
                subtitle: const Text('VIP将优先安排在前排'),
                value: isVip,
                activeTrackColor: AppColors.accent,
                onChanged: (v) => setState(() => isVip = v),
              ),
              const SizedBox(height: AppSpacing.base),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    ref.read(guestListProvider.notifier).add(Guest(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      tag: selectedTag,
                      isVip: isVip,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('添加'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
