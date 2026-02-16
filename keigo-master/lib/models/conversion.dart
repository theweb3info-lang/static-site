import 'dart:convert';
import '../utils/constants.dart';

class Conversion {
  final String id;
  final String input;
  final String output;
  final KeigoLevel level;
  final DateTime timestamp;

  Conversion({
    required this.id,
    required this.input,
    required this.output,
    required this.level,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'input': input,
        'output': output,
        'level': level.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Conversion.fromJson(Map<String, dynamic> json) => Conversion(
        id: json['id'] as String,
        input: json['input'] as String,
        output: json['output'] as String,
        level: KeigoLevel.values.firstWhere((e) => e.name == json['level']),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  static List<Conversion> listFromJson(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => Conversion.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<Conversion> conversions) {
    return jsonEncode(conversions.map((e) => e.toJson()).toList());
  }
}
