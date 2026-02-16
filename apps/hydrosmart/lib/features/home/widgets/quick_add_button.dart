import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/preferences_service.dart';
import '../../../shared/theme/app_theme.dart';

class QuickAddButton extends ConsumerStatefulWidget {
  final int amountMl;
  final IconData icon;
  final String label;

  const QuickAddButton({
    super.key,
    required this.amountMl,
    required this.icon,
    required this.label,
  });

  @override
  ConsumerState<QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends ConsumerState<QuickAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: Material(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.large),
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          onTap: () {
            ref.read(waterRecordsProvider.notifier).addRecord(widget.amountMl);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('+${widget.amountMl}ml 💧'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
              ),
            );
          },
          child: SizedBox(
            width: 80,
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: colorScheme.onPrimaryContainer),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${widget.amountMl}ml',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
