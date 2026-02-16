import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/providers.dart';
import '../model/activity_model.dart';

class AddActivityPage extends ConsumerStatefulWidget {
  const AddActivityPage({super.key});

  @override
  ConsumerState<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends ConsumerState<AddActivityPage> {
  String _selectedType = '一对一聊天';
  double _duration = 30;
  double _energyCost = 10;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('记录社交活动'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity type selection
            Text(
              '活动类型',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: AppConstants.activityEnergyCosts.keys.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                        _energyCost =
                            AppConstants.activityEnergyCosts[type] ?? 10;
                      });
                    }
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Duration slider
            Text(
              '时长：${_duration.toInt()} 分钟',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            Slider(
              value: _duration,
              min: 5,
              max: 240,
              divisions: 47,
              label: '${_duration.toInt()} 分钟',
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _duration = value;
                  // Adjust energy cost based on duration
                  final baseCost =
                      AppConstants.activityEnergyCosts[_selectedType] ?? 10;
                  _energyCost = (baseCost * _duration / 60).clamp(1, 100);
                });
              },
            ),
            const SizedBox(height: AppSpacing.base),

            // Energy cost
            Text(
              '预计能量消耗：${_energyCost.toInt()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            Slider(
              value: _energyCost,
              min: 1,
              max: 100,
              divisions: 99,
              label: '${_energyCost.toInt()}',
              activeColor: AppColors.getBatteryColor(100 - _energyCost),
              onChanged: (value) {
                setState(() {
                  _energyCost = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.base),

            // Note
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: '备注（可选）',
                hintText: '记录一些感受...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Preview card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.getBatteryColor(100 - _energyCost)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          '-${_energyCost.toInt()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color:
                                AppColors.getBatteryColor(100 - _energyCost),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedType,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_duration.toInt()} 分钟 · 消耗 ${_energyCost.toInt()} 能量',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text(
                  '记录活动',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final activity = SocialActivity(
      id: const Uuid().v4(),
      type: _selectedType,
      durationMinutes: _duration.toInt(),
      energyCost: _energyCost,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      createdAt: DateTime.now(),
    );

    ref.read(activitiesProvider.notifier).addActivity(activity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已记录「$_selectedType」，消耗 ${_energyCost.toInt()} 能量'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );

    Navigator.of(context).pop();
  }
}
