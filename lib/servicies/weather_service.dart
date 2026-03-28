// lib/services/weather_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class WeatherService {
  // Замените на ваш реальный ключ из weatherstack dashboard
  static const String _apiKey = '76b0c1c69590147834f658a7ecd49d6a';
  static const String _baseUrl = 'http://api.weatherstack.com/current';

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = Uri.parse('$_baseUrl?access_key=$_apiKey&query=$city&units=m');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Проверка на ошибку в ответе API
        if (data.containsKey('success') && data['success'] == false) {
          print('⚠️ Weatherstack API error: ${data['error']['info']}');
          return _getFallbackWeather(city);
        }
        
        print('✅ Weatherstack API работает!');
        return data;
      } else {
        print('⚠️ Weatherstack HTTP ошибка: ${response.statusCode}');
        return _getFallbackWeather(city);
      }
    } catch (e) {
      print('⚠️ Weatherstack исключение: $e');
      return _getFallbackWeather(city);
    }
  }
  
  // ========== ЗАГЛУШКА (если API не работает) ==========
  Map<String, dynamic> _getFallbackWeather(String city) {
    print('🌤️ Использую заглушку для города: $city');
    
    final now = DateTime.now();
    final hour = now.hour;
    
    // Базовая температура в зависимости от времени суток
    int temperature;
    String description;
    
    if (hour >= 6 && hour < 12) {
      temperature = 3 + (hour - 6) ~/ 2;
      description = 'Утро, свежо';
    } else if (hour >= 12 && hour < 18) {
      temperature = 11 + (hour - 12) ~/ 2;
      description = 'День, тепло';
    } else if (hour >= 18 && hour < 22) {
      temperature = 8 - (hour - 18);
      description = 'Вечер, прохладно';
    } else {
      temperature = 1;
      description = 'Ночь, холодно';
    }
    
    // Добавляем случайные колебания
    final random = Random();
    temperature += random.nextInt(5) - 2;
    final humidity = 40 + random.nextInt(45);
    final windSpeed = random.nextInt(120) / 10;
    
    final weatherTypes = [
      'Ясно', 'Солнечно', 'Малооблачно', 'Переменная облачность',
      'Облачно', 'Пасмурно', 'Ветер'
    ];
    
    String finalDescription;
    if (temperature > 20) {
      finalDescription = 'Жарко, солнечно';
    } else if (temperature < 0) {
      finalDescription = 'Морозно, снег';
    } else {
      finalDescription = weatherTypes[random.nextInt(weatherTypes.length)];
    }
    
    return {
      'current': {
        'temperature': temperature,
        'weather_descriptions': [finalDescription],
        'humidity': humidity,
        'wind_speed': windSpeed,
      }
    };
  }
}