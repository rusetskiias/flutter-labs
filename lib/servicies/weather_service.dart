// lib/services/weather_service.dart

import 'dart:convert';
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
          throw Exception(data['error']['info'] ?? 'Ошибка API weatherstack');
        }
        
        return data;
      } else {
        throw Exception('Ошибка загрузки погоды: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Не удалось загрузить погоду: $e');
    }
  }
}