import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../chores/service/chore_service.dart';
import '../../../app/providers.dart';
import 'home_screen.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _householdNameController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  int _selectedColor = 0;
  bool _isCreating = true; // true = create, false = join

  @override
  void dispose() {
    _householdNameController.dispose();
    _memberNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _createAndJoin() async {
    final memberName = _memberNameController.text.trim();
    if (memberName.isEmpty) return;

    if (_isCreating) {
      final householdName = _householdNameController.text.trim();
      if (householdName.isEmpty) return;
      final household = await ChoreService.createHousehold(householdName);
      final member = await ChoreService.addMember(household.id, memberName, _selectedColor);
      ref.read(currentHouseholdProvider.notifier).state = household;
      ref.read(currentMemberProvider.notifier).state = member;
    } else {
      final code = _inviteCodeController.text.trim();
      if (code.isEmpty) return;
      final household = await ChoreService.joinHousehold(code);
      if (household == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('找不到这个家庭组，请检查邀请码 🤔')),
          );
        }
        return;
      }
      final member = await ChoreService.addMember(household.id, memberName, _selectedColor);
      ref.read(currentHouseholdProvider.notifier).state = household;
      ref.read(currentMemberProvider.notifier).state = member;
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // Logo
              const Text('🏠', style: TextStyle(fontSize: 64), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.base),
              const Text(
                'FairShare',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                '让每份付出都被看见 ✨',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Toggle create/join
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isCreating = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: _isCreating ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Text(
                            '创建家庭组',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _isCreating ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isCreating = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: !_isCreating ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Text(
                            '加入家庭组',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: !_isCreating ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Conditional fields
              if (_isCreating) ...[
                _buildTextField(_householdNameController, '家庭组名称', '如：我们的小窝 🏡', Icons.home_rounded),
              ] else ...[
                _buildTextField(_inviteCodeController, '邀请码', '输入6位邀请码', Icons.vpn_key_rounded),
              ],
              const SizedBox(height: AppSpacing.base),
              _buildTextField(_memberNameController, '你的昵称', '如：小明 😊', Icons.person_rounded),
              const SizedBox(height: AppSpacing.lg),

              // Color picker
              const Text('选择你的代表色', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: List.generate(AppColors.avatarColors.length, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.avatarColors[i],
                        shape: BoxShape.circle,
                        border: _selectedColor == i
                            ? Border.all(color: AppColors.textPrimary, width: 3)
                            : null,
                        boxShadow: _selectedColor == i
                            ? [BoxShadow(color: AppColors.avatarColors[i].withValues(alpha: 0.4), blurRadius: 8)]
                            : null,
                      ),
                      child: _selectedColor == i
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit
              ElevatedButton(
                onPressed: _createAndJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  elevation: 2,
                ),
                child: Text(
                  _isCreating ? '创建并开始 🚀' : '加入家庭组 🤝',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
