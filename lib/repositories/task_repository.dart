import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

/// Repositorio para el manejo de persistencia de tareas
class TaskRepository {
  static const String _tasksKey = 'tasks_key';
  final SharedPreferences _prefs;

  TaskRepository(this._prefs);

  /// Obtiene todas las tareas almacenadas
  Future<List<Task>> getTasks() async {
    try {
      final String? tasksJson = _prefs.getString(_tasksKey);
      if (tasksJson == null || tasksJson.isEmpty) {
        return [];
      }

      final List<dynamic> tasksData = json.decode(tasksJson);
      return tasksData.map((taskJson) => Task.fromJson(taskJson)).toList();
    } catch (e) {
      // En caso de error, retorna lista vacía
      return [];
    }
  }

  /// Guarda la lista completa de tareas
  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final String tasksJson = json.encode(
        tasks.map((task) => task.toJson()).toList(),
      );
      return await _prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      return false;
    }
  }

  /// Limpia todas las tareas almacenadas
  Future<bool> clearTasks() async {
    try {
      return await _prefs.remove(_tasksKey);
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el número de tareas almacenadas
  Future<int> getTaskCount() async {
    final tasks = await getTasks();
    return tasks.length;
  }

  /// Verifica si existe una tarea con el ID especificado
  Future<bool> taskExists(String id) async {
    final tasks = await getTasks();
    return tasks.any((task) => task.id == id);
  }
}