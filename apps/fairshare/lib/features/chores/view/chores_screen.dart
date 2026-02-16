import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../app/providers.dart';
import '../model/chore.dart';
import '../../chores/service/chore_service.dart';
import '../../members/model/member.dart';

class ChoresScreen extends ConsumerStatefulWidget {
  const ChoresScreen({super.key});

  @override
  ConsumerState<ChoresScreen> createState() => _ChoresScreenState();
}

class _ChoresScreenState extends ConsumerState<ChoresScreen> with TickerProviderStateMixin {
  late final ConfettiController _confettiController;
  String? _lastCompletedChoreId;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _completeChore(Chore chore) async {
    final currentMember = ref.read(currentMemberProvider);
    if (currentMember == null) return;

    await ChoreService.completeChore(
      chore.id,
      currentMember.id,
      chore.householdId,
      chore.points,
    );

    setState(() => _lastCompletedChoreId = chore.id);
    _confettiController.play();

    // Trigger refresh
    ref.read(refreshTriggerProvider.notifier).state++;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${chore.emoji} ${chore.name} 完成！+${chore.points}分 🎉'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      );
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _lastCompletedChoreId = null);
    });
  }

  void _showAddChoreDialog() {
    final nameController = TextEditingController();
    final emojiController = TextEditingController(text: '✨');
    int points = 3;

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
              const Text('添加新家务', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.base),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: emojiController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: '家务名称',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Row(
                children: [
                  const Text('积分：', style: TextStyle(fontSize: 16)),
                  ...List.generate(5, (i) => GestureDetector(
                    onTap: () => setSheetState(() => points = i + 1),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: points == i + 1 ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: points == i + 1 ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  final household = ref.read(currentHouseholdProvider);
                  if (household == null) return;
                  await ChoreService.addChore(household.id, name, emojiController.text.trim(), points);
                  ref.invalidate(choresProvider);
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

  void _showMemberPicker(Chore chore) async {
    final members = await ChoreService.getMembers(chore.householdId);
    if (members.length <= 1) {
      _completeChore(chore);
      return;
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${chore.emoji} ${chore.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            const Text('谁完成了这个家务？', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.base),
            ...members.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                onTap: () async {
                  Navigator.pop(ctx);
                  await ChoreService.completeChore(chore.id, m.id, chore.householdId, chore.points);
                  setState(() => _lastCompletedChoreId = chore.id);
                  _confettiController.play();
                  ref.read(refreshTriggerProvider.notifier).state++;
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${m.name} 完成了 ${chore.emoji} ${chore.name}！+${chore.points}分 🎉'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    );
                  }
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) setState(() => _lastCompletedChoreId = null);
                  });
                },
                leading: CircleAvatar(
                  backgroundColor: AppColors.avatarColors[m.avatarColor % AppColors.avatarColors.length],
                  child: Text(m.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final choresAsync = ref.watch(choresProvider);
    final household = ref.watch(currentHouseholdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(household?.name ?? 'FairShare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddChoreDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          choresAsync.when(
            data: (chores) {
              if (chores.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🧹', style: TextStyle(fontSize: 64)),
                      SizedBox(height: AppSpacing.base),
                      Text('还没有家务清单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: AppSpacing.sm),
                      Text('点击右上角 + 添加家务吧！', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.base),
                itemCount: chores.length,
                itemBuilder: (ctx, i) {
                  final chore = chores[i];
                  final isCompleted = _lastCompletedChoreId == chore.id;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    transform: isCompleted
                        ? (Matrix4.identity()..scale(0.95))
                        : Matrix4.identity(),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: InkWell(
                        onTap: () => _showMemberPicker(chore),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isCompleted ? AppColors.success.withValues(alpha: 0.15) : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Center(
                                  child: isCompleted
                                      ? const Icon(Icons.check_circle, color: AppColors.success, size: 28)
                                      : Text(chore.emoji, style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(chore.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text('${chore.points} 积分', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                ),
                                child: const Text('打卡', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                              ),
                            ],
                          ),
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
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: AppColors.avatarColors,
              numberOfParticles: 20,
            ),
          ),
        ],
      ),
    );
  }
}
