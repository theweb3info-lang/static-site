class AppConstants {
  static const String appName = '敬語マスター';
  static const String appNameEn = 'KeigoMaster';
  // Switch between direct OpenAI and proxy:
  // Direct: 'https://api.openai.com/v1' (requires API key on device)
  // Proxy:  'https://ai-api-proxy.YOUR_SUBDOMAIN.workers.dev/v1'
  static const String apiBaseUrl = 'https://api.openai.com/v1';
  static const String chatCompletionsEndpoint = '$apiBaseUrl/chat/completions';
  static const String defaultModel = 'gpt-4o-mini';
  static const int freeTierDailyLimit = 5;
  static const String apiKeyStorageKey = 'openai_api_key';
  static const String historyStorageKey = 'conversion_history';
  static const String dailyCountKey = 'daily_conversion_count';
  static const String dailyCountDateKey = 'daily_conversion_date';
}

enum KeigoLevel {
  teinei('丁寧語', 'Polite language (です/ます)'),
  sonkei('尊敬語', 'Honorific language (respecting others)'),
  kenjou('謙譲語', 'Humble language (lowering yourself)'),
  business('ビジネスメール', 'Business email style');

  final String label;
  final String description;
  const KeigoLevel(this.label, this.description);
}
