/// Maps known allergen aliases to their parent allergen category.
class AllergenDatabase {
  static const Map<String, String> aliasMap = {
    // Milk
    'casein': 'milk', 'whey': 'milk', 'lactose': 'milk',
    'ghee': 'milk', 'curds': 'milk', 'cream': 'milk',
    'butter': 'milk', 'buttermilk': 'milk', 'cheese': 'milk',
    'yogurt': 'milk', 'lactalbumin': 'milk', 'lactoferrin': 'milk',
    // Eggs
    'albumin': 'eggs', 'globulin': 'eggs', 'lysozyme': 'eggs',
    'mayonnaise': 'eggs', 'meringue': 'eggs', 'ovalbumin': 'eggs',
    'ovomucin': 'eggs', 'ovomucoid': 'eggs',
    // Peanuts
    'arachis': 'peanuts', 'groundnut': 'peanuts', 'monkey nuts': 'peanuts',
    // Tree Nuts
    'almond': 'tree_nuts', 'cashew': 'tree_nuts', 'walnut': 'tree_nuts',
    'pecan': 'tree_nuts', 'pistachio': 'tree_nuts', 'macadamia': 'tree_nuts',
    'hazelnut': 'tree_nuts', 'brazil nut': 'tree_nuts', 'filbert': 'tree_nuts',
    'praline': 'tree_nuts', 'marzipan': 'tree_nuts', 'nougat': 'tree_nuts',
    // Wheat
    'gluten': 'wheat', 'flour': 'wheat', 'semolina': 'wheat',
    'spelt': 'wheat', 'kamut': 'wheat', 'durum': 'wheat',
    'couscous': 'wheat', 'bulgur': 'wheat', 'farina': 'wheat',
    // Soy
    'soya': 'soy', 'lecithin': 'soy', 'tofu': 'soy',
    'edamame': 'soy', 'miso': 'soy', 'tempeh': 'soy',
    // Fish
    'anchovy': 'fish', 'sardine': 'fish', 'fish sauce': 'fish',
    'fish oil': 'fish', 'omega-3': 'fish',
    // Shellfish
    'shrimp': 'shellfish', 'crab': 'shellfish', 'lobster': 'shellfish',
    'prawn': 'shellfish', 'crayfish': 'shellfish', 'scallop': 'shellfish',
    'clam': 'shellfish', 'mussel': 'shellfish', 'oyster': 'shellfish',
    // Sesame
    'tahini': 'sesame', 'sesame oil': 'sesame', 'halvah': 'sesame',
  };

  /// Quick local check before AI analysis.
  static Map<String, String> quickScan(String text, List<String> userAllergens) {
    final lower = text.toLowerCase();
    final found = <String, String>{};
    for (final entry in aliasMap.entries) {
      if (lower.contains(entry.key) && userAllergens.contains(entry.value)) {
        found[entry.key] = entry.value;
      }
    }
    // Also check direct allergen names
    for (final allergen in userAllergens) {
      if (lower.contains(allergen.toLowerCase())) {
        found[allergen] = allergen;
      }
    }
    return found;
  }
}
