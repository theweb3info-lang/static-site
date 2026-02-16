import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/theme/app_theme.dart';

class ExcusesPage extends StatefulWidget {
  const ExcusesPage({super.key});

  @override
  State<ExcusesPage> createState() => _ExcusesPageState();
}

class _ExcusesPageState extends State<ExcusesPage> {
  String? _highlightedExcuse;
  final _random = Random();

  void _randomExcuse() {
    HapticFeedback.lightImpact();
    setState(() {
      _highlightedExcuse = AppConstants
          .exitExcuses[_random.nextInt(AppConstants.exitExcuses.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.base, AppSpacing.base, AppSpacing.base, 0),
          child: Column(
            children: [
              Text(
                '退场借口生成器',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '需要离开时，选一个借口吧 🏃',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _randomExcuse,
                  icon: const Icon(Icons.casino),
                  label: const Text(
                    '随机一个借口',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            itemCount: AppConstants.exitExcuses.length,
            itemBuilder: (context, index) {
              final excuse = AppConstants.exitExcuses[index];
              final isHighlighted = excuse == _highlightedExcuse;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : (isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isHighlighted
                          ? AppColors.accent
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                      width: isHighlighted ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      excuse,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isHighlighted ? FontWeight.w600 : FontWeight.normal,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.copy,
                        size: 18,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: excuse));
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('借口已复制，祝你顺利撤退 🏃‍♂️'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _highlightedExcuse = excuse;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
