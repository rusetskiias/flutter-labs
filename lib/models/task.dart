// lib/models/task.dart

class Task {
  final String title;
  bool isDone;

  Task({
    required this.title,
    this.isDone = false,
  });

  // Преобразование в Map для сохранения в shared_preferences
  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
      };

  // Создание Task из Map (для загрузки из shared_preferences)
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isDone: json['isDone'],
      );
}