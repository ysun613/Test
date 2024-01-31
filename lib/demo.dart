import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getWeatherData(String city) async {
  final apiKey = '576ab16d26e14d18885144958243001';
  final apiUrl = 'https://api.weatherapi.com/v1/current.json?q=$city&key=$apiKey';
  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      print('Failed to load weather data: ${response.statusCode}');
      return {};
    }
  } catch (e) {
    print('Error loading weather data: $e');
    return {};
    // vfdvdfvdfvd
  }
}

void main() async {
  final city = 'Atlanta';
  final weatherData = await getWeatherData(city);

  if (weatherData.isNotEmpty) {
    final location = weatherData['location']['name'];
    final temperature = weatherData['current']['temp_c'];
    final condition = weatherData['current']['condition']['text'];

    print('Current weather in $location: $condition');
    print('Temperature in $location: $temperature°C');
  } else {
    print('Unable to fetch weather data for $city.');
  }
}
