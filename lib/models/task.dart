import 'package:uuid/uuid.dart';

/// Enumeración para las prioridades de las tareas
enum TaskPriority {
  high('Alta', 3),
  medium('Media', 2),
  low('Baja', 1);

  const TaskPriority(this.displayName, this.value);
  final String displayName;
  final int value;

  /// Convierte un string a TaskPriority
  static TaskPriority fromString(String priority) {
    switch (priority) {
      case 'Alta':
        return TaskPriority.high;
      case 'Media':
        return TaskPriority.medium;
      case 'Baja':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}

/// Modelo de tarea con todas las propiedades necesarias
class Task {
  final String id;
  String title;
  String? description;
  TaskPriority priority;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    String? id,
    required this.title,
    this.description,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Convierte la tarea a JSON para persistencia
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.displayName,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Crea una tarea desde JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: TaskPriority.fromString(json['priority'] ?? 'Media'),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }

  /// Crea una copia de la tarea con valores modificados
  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Marca la tarea como completada o pendiente
  void toggleCompleted() {
    isCompleted = !isCompleted;
    if (isCompleted) {
      completedAt = DateTime.now();
    } else {
      completedAt = null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: ${priority.displayName}, '
           'isCompleted: $isCompleted)';
  }
}