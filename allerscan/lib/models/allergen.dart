class Allergen {
  final String id;
  final String name;
  final String emoji;
  final List<String> aliases;

  const Allergen({
    required this.id,
    required this.name,
    required this.emoji,
    this.aliases = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'aliases': aliases,
      };

  factory Allergen.fromJson(Map<String, dynamic> json) => Allergen(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String,
        aliases: List<String>.from(json['aliases'] ?? []),
      );
}
