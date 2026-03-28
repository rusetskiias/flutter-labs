// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../servicies/task_service.dart';
import '../models/task.dart';
import 'weather_rates_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final TaskService _taskService = TaskService();

  // Загрузка задач при запуске
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Загрузка из SharedPreferences
  Future<void> _loadTasks() async {
    final tasks = await _taskService.loadTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  // Сохранение в SharedPreferences
  Future<void> _saveTasks() async {
    await _taskService.saveTasks(_tasks);
  }

  // Добавление задачи
  void _addTask() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: text));
        _controller.clear();
      });
      _saveTasks(); // Сохраняем после добавления
    }
  }

  // Удаление задачи
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks(); // Сохраняем после удаления
  }

  // Переключение статуса выполнения
  void _toggleTaskStatus(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
    _saveTasks(); // Сохраняем после изменения
  }

  // Подсчет выполненных задач
  int get _doneCount {
    return _tasks.where((task) => task.isDone).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои дела'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeatherRatesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.wb_sunny),
          ),
        ],
      ),
      body: Column(
        children: [
          // Поле ввода и кнопка "Добавить"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Введите задачу...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Добавить'),
                ),
              ],
            ),
          ),
          
          // Список задач
          Expanded(
            child: _tasks.isEmpty
                ? const Center(
                    child: Text(
                      'Нет задач. Добавьте первую!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      
                      return ListTile(
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (_) => _toggleTaskStatus(index),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isDone ? Colors.grey : Colors.black,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () => _deleteTask(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      );
                    },
                  ),
          ),
          
          // Статистика
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Text(
              'Всего задач: ${_tasks.length} | Выполнено: $_doneCount',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}