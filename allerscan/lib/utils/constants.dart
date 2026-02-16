import '../models/allergen.dart';

class AppConstants {
  static const String appName = 'AllerScan';
  static const int freeTierDailyScans = 3;
  static const double proPrice = 4.99;

  // Switch between direct OpenAI and proxy:
  // Direct: 'https://api.openai.com/v1' (requires API key on device)
  // Proxy:  'https://ai-api-proxy.YOUR_SUBDOMAIN.workers.dev/v1'
  static const String apiBaseUrl = 'https://api.openai.com/v1';
  static const String chatCompletionsEndpoint = '$apiBaseUrl/chat/completions';

  static const List<Allergen> commonAllergens = [
    Allergen(id: 'milk', name: 'Milk', emoji: '🥛', aliases: ['casein', 'whey', 'lactose', 'ghee', 'curds']),
    Allergen(id: 'eggs', name: 'Eggs', emoji: '🥚', aliases: ['albumin', 'globulin', 'lysozyme', 'mayonnaise', 'meringue']),
    Allergen(id: 'peanuts', name: 'Peanuts', emoji: '🥜', aliases: ['arachis', 'groundnut', 'monkey nuts']),
    Allergen(id: 'tree_nuts', name: 'Tree Nuts', emoji: '🌰', aliases: ['almond', 'cashew', 'walnut', 'pecan', 'pistachio', 'macadamia', 'hazelnut', 'brazil nut']),
    Allergen(id: 'wheat', name: 'Wheat', emoji: '🌾', aliases: ['gluten', 'flour', 'semolina', 'spelt', 'kamut', 'durum']),
    Allergen(id: 'soy', name: 'Soy', emoji: '🫘', aliases: ['soya', 'lecithin', 'tofu', 'edamame', 'miso', 'tempeh']),
    Allergen(id: 'fish', name: 'Fish', emoji: '🐟', aliases: ['cod', 'salmon', 'anchovy', 'sardine', 'fish sauce', 'fish oil']),
    Allergen(id: 'shellfish', name: 'Shellfish', emoji: '🦐', aliases: ['shrimp', 'crab', 'lobster', 'prawn', 'crayfish', 'scallop']),
    Allergen(id: 'sesame', name: 'Sesame', emoji: '🫙', aliases: ['tahini', 'sesame oil', 'halvah']),
  ];
}
