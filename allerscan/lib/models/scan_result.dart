class FoundAllergen {
  final String name;
  final String sourceIngredient;
  final String allergenCategory;
  final String confidence; // "high", "medium", "low"

  const FoundAllergen({
    required this.name,
    required this.sourceIngredient,
    required this.allergenCategory,
    required this.confidence,
  });

  factory FoundAllergen.fromJson(Map<String, dynamic> json) => FoundAllergen(
        name: json['name'] as String? ?? '',
        sourceIngredient: json['source_ingredient'] as String? ?? '',
        allergenCategory: json['allergen_category'] as String? ?? '',
        confidence: json['confidence'] as String? ?? 'medium',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'source_ingredient': sourceIngredient,
        'allergen_category': allergenCategory,
        'confidence': confidence,
      };
}

class ScanResult {
  final String id;
  final String? imagePath;
  final String extractedText;
  final bool safe;
  final List<FoundAllergen> foundAllergens;
  final List<String> warnings;
  final DateTime timestamp;

  const ScanResult({
    required this.id,
    this.imagePath,
    required this.extractedText,
    required this.safe,
    required this.foundAllergens,
    required this.warnings,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'extractedText': extractedText,
        'safe': safe,
        'foundAllergens': foundAllergens.map((e) => e.toJson()).toList(),
        'warnings': warnings,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String?,
        extractedText: json['extractedText'] as String? ?? '',
        safe: json['safe'] as bool? ?? true,
        foundAllergens: (json['foundAllergens'] as List?)
                ?.map((e) => FoundAllergen.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        warnings: List<String>.from(json['warnings'] ?? []),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
