import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/weather_rates_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Мои дела',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // Здесь можно менять экран для проверки
      // home: QuotesScreen(), // Раскомментировать для проверки экрана цитат
    );
  }
}