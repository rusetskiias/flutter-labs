// lib/screens/weather_rates_screen.dart

import 'package:flutter/material.dart';
import '../servicies/weather_service.dart';
import '../servicies/currency_service.dart';

class WeatherRatesScreen extends StatefulWidget {
  const WeatherRatesScreen({super.key});

  @override
  State<WeatherRatesScreen> createState() => _WeatherRatesScreenState();
}

class _WeatherRatesScreenState extends State<WeatherRatesScreen> {
  final WeatherService _weatherService = WeatherService();
  final CurrencyService _currencyService = CurrencyService();
  
  // Состояние загрузки и данных
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Данные погоды
  String _city = 'Москва';
  double _temperature = 0;
  String _description = '';
  int _humidity = 0;
  double _windSpeed = 0;
  
  // Данные курсов валют
  Map<String, double> _rates = {};
  
  // Время последнего обновления
  String _lastUpdated = '';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Загрузка всех данных
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // Загружаем погоду и курсы параллельно
      await Future.wait([
        _loadWeather(),
        _loadRates(),
      ]);
      
      setState(() {
        _lastUpdated = _getCurrentTime();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Загрузка погоды (weatherstack)
  Future<void> _loadWeather() async {
    try {
      final data = await _weatherService.getWeather(_city);
      
      // WeatherStack возвращает данные в поле 'current'
      final current = data['current'];
      
      setState(() {
        _temperature = current['temperature'].toDouble();
        _description = current['weather_descriptions'][0];
        _humidity = current['humidity'];
        _windSpeed = current['wind_speed'].toDouble();
      });
    } catch (e) {
      throw Exception('Ошибка загрузки погоды');
    }
  }

  // Загрузка курсов валют
  Future<void> _loadRates() async {
    try {
      final rates = await _currencyService.getRates();
      setState(() {
        _rates = rates;
      });
    } catch (e) {
      throw Exception('Ошибка загрузки курсов');
    }
  }

  // Получение текущего времени
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.day}.${now.month}.${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Погода и курсы'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: _loadAllData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка данных...'),
          ],
        ),
      );
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Ошибка: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllData,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // ========== КАРТОЧКА ПОГОДЫ ==========
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _city,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadAllData,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Простая иконка солнца (weatherstack не дает иконки в бесплатной версии)
                  const Icon(
                    Icons.wb_sunny,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_temperature.round()}°C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _description,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Влажность: $_humidity% | Ветер: ${_windSpeed.toStringAsFixed(1)} м/с',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // ========== КАРТОЧКА КУРСА ВАЛЮТ ==========
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Курсы валют',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadAllData,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: const Text('USD / RUB'),
                trailing: Text(
                  _rates['USD/RUB']?.toStringAsFixed(2) ?? '--',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.euro, color: Colors.blue),
                title: const Text('EUR / RUB'),
                trailing: Text(
                  _rates['EUR/RUB']?.toStringAsFixed(2) ?? '--',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.currency_yuan, color: Colors.red),
                title: const Text('CNY / RUB'),
                trailing: Text(
                  _rates['CNY/RUB']?.toStringAsFixed(2) ?? '--',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Обновлено:', style: TextStyle(fontSize: 12)),
                    Text(
                      _lastUpdated,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}