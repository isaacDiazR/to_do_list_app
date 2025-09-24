import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'add_edit_task_screen.dart';

/// Pantalla principal que muestra la lista de tareas
class TaskListScreen extends StatefulWidget {
  final TaskService taskService;

  const TaskListScreen({
    super.key,
    required this.taskService,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _filteredTasks = [];
  TaskPriority? _selectedPriority;
  String _searchQuery = '';
  bool _showCompletedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// Carga las tareas y aplica filtros
  Future<void> _loadTasks() async {
    await widget.taskService.loadTasks();
    _applyFilters();
  }

  /// Aplica los filtros activos a la lista de tareas
  void _applyFilters() {
    setState(() {
      _filteredTasks = widget.taskService.tasks;

      // Filtrar por prioridad
      if (_selectedPriority != null) {
        _filteredTasks = _filteredTasks
            .where((task) => task.priority == _selectedPriority)
            .toList();
      }

      // Filtrar por estado de completado
      if (_showCompletedOnly) {
        _filteredTasks = _filteredTasks
            .where((task) => task.isCompleted)
            .toList();
      }

      // Filtrar por búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        _filteredTasks = _filteredTasks.where((task) {
          final titleMatch = task.title.toLowerCase().contains(query);
          final descriptionMatch = 
              task.description?.toLowerCase().contains(query) ?? false;
          return titleMatch || descriptionMatch;
        }).toList();
      }
    });
  }

  /// Navega a la pantalla de agregar tarea
  Future<void> _navigateToAddTask() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(
          taskService: widget.taskService,
        ),
      ),
    );

    if (result == true) {
      _loadTasks();
    }
  }

  /// Navega a la pantalla de editar tarea
  Future<void> _navigateToEditTask(Task task) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(
          taskService: widget.taskService,
          task: task,
        ),
      ),
    );

    if (result == true) {
      _loadTasks();
    }
  }

  /// Alterna el estado de completado de una tarea
  Future<void> _toggleTaskCompletion(String taskId) async {
    try {
      await widget.taskService.toggleTaskCompletion(taskId);
      _loadTasks();
    } catch (e) {
      _showErrorSnackBar('Error al actualizar la tarea: $e');
    }
  }

  /// Elimina una tarea con confirmación
  Future<void> _deleteTask(String taskId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed) {
      try {
        await widget.taskService.deleteTask(taskId);
        _loadTasks();
        _showSuccessSnackBar('Tarea eliminada correctamente');
      } catch (e) {
        _showErrorSnackBar('Error al eliminar la tarea: $e');
      }
    }
  }

  /// Muestra diálogo de confirmación para eliminar
  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Muestra SnackBar de éxito
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Muestra SnackBar de error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Obtiene el color según la prioridad de la tarea
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  /// Construye el widget de filtros
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar tareas...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),
          
          // Filtros por prioridad y estado
          Column(
            children: [
              DropdownButtonFormField<TaskPriority?>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Filtrar por prioridad',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<TaskPriority?>(
                    value: null,
                    child: Text('Todas las prioridades'),
                  ),
                  ...TaskPriority.values.map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.displayName),
                    ),
                  ),
                ],
                onChanged: (value) {
                  _selectedPriority = value;
                  _applyFilters();
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _showCompletedOnly,
                onChanged: (value) {
                  _showCompletedOnly = value ?? false;
                  _applyFilters();
                },
                title: const Text('Solo tareas completadas'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye el widget de estadísticas
  Widget _buildStatistics() {
    final counts = widget.taskService.taskCounts;
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total', counts['total']!, Colors.blue),
          _buildStatCard('Pendientes', counts['pending']!, Colors.orange),
          _buildStatCard('Completadas', counts['completed']!, Colors.green),
        ],
      ),
    );
  }

  /// Construye una tarjeta de estadística
  Widget _buildStatCard(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildStatistics(),
          _buildFilters(),
          Expanded(
            child: _filteredTasks.isEmpty
                ? const Center(
                    child: Text(
                      'No hay tareas que mostrar',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Indicador de prioridad
                              Container(
                                width: 4,
                                height: 40,
                                color: _getPriorityColor(task.priority),
                              ),
                              const SizedBox(width: 8),
                              // Checkbox para marcar como completado
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) => 
                                    _toggleTaskCompletion(task.id),
                              ),
                            ],
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              color: task.isCompleted 
                                  ? Colors.grey 
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task.description != null)
                                Text(
                                  task.description!,
                                  style: TextStyle(
                                    color: task.isCompleted 
                                        ? Colors.grey 
                                        : null,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                'Prioridad: ${task.priority.displayName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getPriorityColor(task.priority),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _navigateToEditTask(task),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTask(task.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}