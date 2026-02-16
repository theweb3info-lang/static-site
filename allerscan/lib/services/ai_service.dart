import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/scan_result.dart';
import '../utils/allergen_prompts.dart';

class AiService {
  final String apiKey;

  AiService({required this.apiKey});

  Future<ScanResult> analyzeIngredients({
    required String ocrText,
    required List<String> userAllergens,
    String? imagePath,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': AllergenPrompts.systemPrompt},
          {
            'role': 'user',
            'content': AllergenPrompts.buildUserPrompt(ocrText, userAllergens),
          },
        ],
        'temperature': 0.1,
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI analysis failed: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['choices'][0]['message']['content'] as String;

    // Parse JSON from response (handle markdown code blocks)
    String jsonStr = content.trim();
    if (jsonStr.startsWith('```')) {
      jsonStr = jsonStr.replaceAll(RegExp(r'^```\w*\n?'), '').replaceAll(RegExp(r'\n?```$'), '');
    }

    final result = jsonDecode(jsonStr) as Map<String, dynamic>;

    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      extractedText: ocrText,
      safe: result['safe'] as bool? ?? true,
      foundAllergens: (result['found_allergens'] as List?)
              ?.map((e) => FoundAllergen.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      warnings: List<String>.from(result['warnings'] ?? []),
      timestamp: DateTime.now(),
    );
  }
}
