import '../models/task.dart';
import '../repositories/task_repository.dart';

/// Servicio para el manejo de lógica de negocio de tareas
class TaskService {
  final TaskRepository _repository;
  List<Task> _tasks = [];

  TaskService(this._repository);

  /// Obtiene todas las tareas
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Obtiene el contador de tareas por estado
  Map<String, int> get taskCounts => {
    'total': _tasks.length,
    'completed': _tasks.where((task) => task.isCompleted).length,
    'pending': _tasks.where((task) => !task.isCompleted).length,
  };

  /// Carga las tareas desde el repositorio
  Future<void> loadTasks() async {
    _tasks = await _repository.getTasks();
    // Ordenar por prioridad y fecha de creación
    _tasks.sort((a, b) {
      if (a.priority.value != b.priority.value) {
        return b.priority.value.compareTo(a.priority.value); // Mayor prioridad primero
      }
      return b.createdAt.compareTo(a.createdAt); // Más recientes primero
    });
  }

  /// Agrega una nueva tarea
  Future<bool> addTask({
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    // Validación: el título no puede estar vacío
    if (title.trim().isEmpty) {
      throw ArgumentError('El título de la tarea no puede estar vacío');
    }

    final task = Task(
      title: title.trim(),
      description: description?.trim(),
      priority: priority,
    );

    _tasks.add(task);
    await _sortTasks();
    return await _repository.saveTasks(_tasks);
  }

  /// Edita una tarea existente
  Future<bool> editTask(
    String id, {
    String? title,
    String? description,
    TaskPriority? priority,
  }) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) {
      throw ArgumentError('Tarea con ID $id no encontrada');
    }

    // Validación: si se proporciona título, no puede estar vacío
    if (title != null && title.trim().isEmpty) {
      throw ArgumentError('El título de la tarea no puede estar vacío');
    }

    final task = _tasks[taskIndex];
    _tasks[taskIndex] = task.copyWith(
      title: title?.trim(),
      description: description?.trim(),
      priority: priority,
    );

    await _sortTasks();
    return await _repository.saveTasks(_tasks);
  }

  /// Elimina una tarea
  Future<bool> deleteTask(String id) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) {
      throw ArgumentError('Tarea con ID $id no encontrada');
    }

    _tasks.removeAt(taskIndex);
    return await _repository.saveTasks(_tasks);
  }

  /// Marca una tarea como completada o pendiente
  Future<bool> toggleTaskCompletion(String id) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) {
      throw ArgumentError('Tarea con ID $id no encontrada');
    }

    _tasks[taskIndex].toggleCompleted();
    return await _repository.saveTasks(_tasks);
  }

  /// Filtra tareas por prioridad
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  /// Filtra tareas por estado de completado
  List<Task> getTasksByStatus({required bool isCompleted}) {
    return _tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  /// Busca tareas por título o descripción
  List<Task> searchTasks(String query) {
    if (query.trim().isEmpty) return _tasks;

    final lowerQuery = query.toLowerCase();
    return _tasks.where((task) {
      final titleMatch = task.title.toLowerCase().contains(lowerQuery);
      final descriptionMatch = task.description
          ?.toLowerCase()
          .contains(lowerQuery) ?? false;
      return titleMatch || descriptionMatch;
    }).toList();
  }

  /// Obtiene una tarea por ID
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Limpia todas las tareas
  Future<bool> clearAllTasks() async {
    _tasks.clear();
    return await _repository.clearTasks();
  }

  /// Agrega múltiples tareas de forma eficiente (para pruebas de rendimiento)
  Future<bool> addMultipleTasks(List<Map<String, dynamic>> tasksData) async {
    for (var taskData in tasksData) {
      final task = Task(
        title: taskData['title'] ?? 'Tarea sin título',
        description: taskData['description'],
        priority: taskData['priority'] ?? TaskPriority.medium,
      );
      _tasks.add(task);
    }
    
    await _sortTasks();
    return await _repository.saveTasks(_tasks);
  }

  /// Ordena las tareas por prioridad y fecha
  Future<void> _sortTasks() async {
    _tasks.sort((a, b) {
      if (a.priority.value != b.priority.value) {
        return b.priority.value.compareTo(a.priority.value);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  }
}