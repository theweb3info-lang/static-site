import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../app/providers.dart';
import '../../chores/service/chore_service.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);
    final household = ref.watch(currentHouseholdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('家庭成员 👨‍👩‍👧‍👦')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Invite code card
            if (household != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    children: [
                      const Text('邀请码', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: household.inviteCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('邀请码已复制 📋'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                household.inviteCode,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text('点击复制，分享给家人/室友', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            // Members list
            membersAsync.when(
              data: (members) {
                if (members.isEmpty) {
                  return const Center(child: Text('还没有成员'));
                }
                return Column(
                  children: members.map((m) {
                    final color = AppColors.avatarColors[m.avatarColor % AppColors.avatarColors.length];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          radius: 24,
                          child: Text(m.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        subtitle: Text('加入于 ${m.createdAt.month}/${m.createdAt.day}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Add member button
            OutlinedButton.icon(
              onPressed: () => _showAddMemberDialog(context, ref),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('添加成员'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    int selectedColor = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
              MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('添加家庭成员', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.base),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '昵称',
                  hintText: '如：小红 😊',
                  prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              const Text('选择代表色', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                children: List.generate(AppColors.avatarColors.length, (i) {
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedColor = i),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.avatarColors[i],
                        shape: BoxShape.circle,
                        border: selectedColor == i ? Border.all(color: AppColors.textPrimary, width: 3) : null,
                      ),
                      child: selectedColor == i ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  final household = ref.read(currentHouseholdProvider);
                  if (household == null) return;
                  await ChoreService.addMember(household.id, name, selectedColor);
                  ref.invalidate(membersProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: const Text('添加 ✅', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
