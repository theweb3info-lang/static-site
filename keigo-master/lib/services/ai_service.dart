import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/keigo_prompts.dart';
import 'storage_service.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(ref.watch(storageServiceProvider));
});

class AiService {
  final StorageService _storage;
  AiService(this._storage);

  Future<String> convertToKeigo(String input, KeigoLevel level) async {
    final apiKey = _storage.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('APIキーが設定されていません');
    }

    final response = await http.post(
      Uri.parse(AppConstants.chatCompletionsEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': AppConstants.defaultModel,
        'messages': [
          {'role': 'system', 'content': KeigoPrompts.systemPrompt(level)},
          {'role': 'user', 'content': input},
        ],
        'temperature': 0.3,
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final errorMsg = body['error']?['message'] ?? 'Unknown error';
      throw Exception('API Error (${ response.statusCode}): $errorMsg');
    }

    final body = jsonDecode(response.body);
    return body['choices'][0]['message']['content'] as String;
  }
}
