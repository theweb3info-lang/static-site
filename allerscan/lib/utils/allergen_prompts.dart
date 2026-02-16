class AllergenPrompts {
  static const String systemPrompt = '''You are an allergen detection expert. Given ingredient text from a food product label and a user's allergen list, identify ALL ingredients that contain or may contain the user's allergens.

Include hidden allergens:
- casein, whey, lactose, ghee, curds = milk protein
- albumin, globulin, lysozyme = egg
- lecithin = often soy (unless specified as sunflower lecithin)
- arachis = peanut
- semolina, spelt, kamut, durum = wheat/gluten
- tahini = sesame
- natural flavors = may contain any allergen

Return ONLY valid JSON with this exact structure:
{
  "safe": bool,
  "found_allergens": [
    {
      "name": "ingredient name found in text",
      "source_ingredient": "exact text from label",
      "allergen_category": "which allergen category (e.g., milk, eggs, soy)",
      "confidence": "high" | "medium" | "low"
    }
  ],
  "warnings": ["any additional warnings about cross-contamination or ambiguous ingredients"]
}

If no allergens are found, return {"safe": true, "found_allergens": [], "warnings": []}.
Be thorough but avoid false positives. If unsure, use confidence "low" and add a warning.''';

  static String buildUserPrompt(String ocrText, List<String> allergens) {
    return '''Ingredient text from food label:
"""
$ocrText
"""

User's allergens: ${allergens.join(', ')}

Analyze the ingredients and identify any allergens. Return JSON only.''';
  }
}
