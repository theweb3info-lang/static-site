import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_theme.dart';
import '../service/capsule_provider.dart';

class CreateCapsulePage extends ConsumerStatefulWidget {
  const CreateCapsulePage({super.key});

  @override
  ConsumerState<CreateCapsulePage> createState() => _CreateCapsulePageState();
}

class _CreateCapsulePageState extends ConsumerState<CreateCapsulePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _unlockDate;
  String _selectedMood = '💌';
  bool _isSaving = false;

  final _moods = ['💌', '🥰', '😊', '🌟', '🎯', '💪', '🌈', '🎁', '🌸', '☕'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _unlockDate = date);
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('给这封信起个标题吧 ✍️');
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      _showError('写点什么给未来的自己吧 💭');
      return;
    }
    if (_unlockDate == null) {
      _showError('选择一个未来的日期 📅');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(capsuleListProvider.notifier).createCapsule(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        unlockAt: _unlockDate!,
        mood: _selectedMood,
      );
      if (mounted) {
        _showSuccess();
      }
    } catch (e) {
      if (mounted) _showError('保存失败，请重试');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📮', style: TextStyle(fontSize: 56))
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                '信已封存',
                style: Theme.of(ctx).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '将在 ${DateFormat('yyyy年M月d日').format(_unlockDate!)} 解锁',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '在那之前，它会安静地等待着...',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('好的'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('写一封信'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('封存 📮', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood selector
            const Text(
              '此刻的心情',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _moods.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final isSelected = _moods[i] == _selectedMood;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = _moods[i]),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(_moods[i], style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Title
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: '给这封信起个标题...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 16),

            // Content
            TextField(
              controller: _contentController,
              style: const TextStyle(fontSize: 15, height: 1.8),
              decoration: const InputDecoration(
                hintText: '亲爱的未来的我...\n\n想对未来的自己说些什么？',
                hintStyle: TextStyle(color: AppColors.textTertiary, height: 1.8),
                alignLabelWithHint: true,
              ),
              maxLines: 12,
              minLines: 8,
              maxLength: 5000,
            ),
            const SizedBox(height: 24),

            // Unlock date
            const Text(
              '选择解锁日期',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _unlockDate != null
                          ? DateFormat('yyyy年M月d日').format(_unlockDate!)
                          : '选择一个未来的日期...',
                      style: TextStyle(
                        fontSize: 15,
                        color: _unlockDate != null
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    if (_unlockDate != null)
                      Text(
                        '${_unlockDate!.difference(DateTime.now()).inDays}天后',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick date suggestions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickDate('1个月后', 30),
                _buildQuickDate('3个月后', 90),
                _buildQuickDate('半年后', 180),
                _buildQuickDate('1年后', 365),
                _buildQuickDate('生日', null),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDate(String label, int? days) {
    return GestureDetector(
      onTap: () {
        if (days != null) {
          setState(() => _unlockDate = DateTime.now().add(Duration(days: days)));
        } else {
          _pickDate();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
