// lib/services/currency_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Используем стабильный бесплатный API без ключа
  static const String _baseUrl = 'https://api.freecurrencyapi.com/v1/latest';
  
  // Публичный демо-ключ (ограничен, но работает)
  static const String _apiKey = 'fca_live_SBqVjrN1DSsc7S62GlaAxiMvujO3c6e5rOXn9ZQy';

  Future<Map<String, double>> getRates() async {
    final url = Uri.parse('$_baseUrl?apikey=$_apiKey&base_currency=USD&currencies=RUB,EUR,CNY');
    
    try {
      print('🔄 Загрузка курсов валют...');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );
      
      print('Currency API status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Currency API ответ получен');
        
        if (data.containsKey('data')) {
          final rates = data['data'];
          return {
            'USD/RUB': (rates['RUB'] ?? 85.50).toDouble(),
            'EUR/RUB': (rates['EUR'] ?? 92.30).toDouble(),
            'CNY/RUB': (rates['CNY'] ?? 11.75).toDouble(),
          };
        } else {
          throw Exception('Неверный формат ответа API');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка API курсов: $e');
      print('⚠️ Использую заглушку');
      // Возвращаем заглушку, если API недоступен
      return {
        'USD/RUB': 85.50,
        'EUR/RUB': 92.30,
        'CNY/RUB': 11.75,
      };
    }
  }
}