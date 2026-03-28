// lib/services/task_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  // Ключ для сохранения в SharedPreferences
  static const String _tasksKey = 'tasks';

  // Сохранение списка задач
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    // Преобразуем список задач в JSON-строку
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_tasksKey, jsonEncode(tasksJson));
  }

  // Загрузка списка задач
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString(_tasksKey);
    
    // Если сохраненных задач нет — возвращаем пустой список
    if (tasksString == null) return [];
    
    // Преобразуем JSON-строку обратно в список задач
    final List<dynamic> tasksJson = jsonDecode(tasksString);
    return tasksJson.map((json) => Task.fromJson(json)).toList();
  }
}