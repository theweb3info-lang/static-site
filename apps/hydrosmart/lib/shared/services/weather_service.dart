import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  /// Fetches current temperature from Open-Meteo for given coordinates.
  /// Returns temperature in °C or null on failure.
  static Future<double?> fetchTemperature({
    double latitude = 1.3521, // default Singapore
    double longitude = 103.8198,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitude&longitude=$longitude'
        '&current_weather=true',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['current_weather']['temperature'] as num).toDouble();
      }
    } catch (_) {}
    return null;
  }
}
