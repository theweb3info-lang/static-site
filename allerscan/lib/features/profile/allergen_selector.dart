import 'package:flutter/material.dart';
import '../../models/allergen.dart';

class AllergenSelector extends StatelessWidget {
  final List<Allergen> allergens;
  final List<String> selectedIds;
  final ValueChanged<String> onToggle;

  const AllergenSelector({
    super.key,
    required this.allergens,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: allergens.length,
      itemBuilder: (context, index) {
        final allergen = allergens[index];
        final selected = selectedIds.contains(allergen.id);

        return GestureDetector(
          onTap: () => onToggle(allergen.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? Colors.red : Colors.grey.shade200,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(allergen.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text(
                  allergen.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? Colors.red.shade700 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (selected)
                  Icon(Icons.check_circle, color: Colors.red.shade400, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
