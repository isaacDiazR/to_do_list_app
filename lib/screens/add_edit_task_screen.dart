import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

/// Pantalla para agregar o editar una tarea
class AddEditTaskScreen extends StatefulWidget {
  final TaskService taskService;
  final Task? task; // Si es null, se está agregando una nueva tarea

  const AddEditTaskScreen({
    super.key,
    required this.taskService,
    this.task,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Inicializa los campos si se está editando una tarea existente
  void _initializeFields() {
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedPriority = widget.task!.priority;
    }
  }

  /// Valida y guarda la tarea
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      if (widget.task == null) {
        // Agregar nueva tarea
        await widget.taskService.addTask(
          title: title,
          description: description.isEmpty ? null : description,
          priority: _selectedPriority,
        );
        _showSuccessSnackBar('Tarea agregada correctamente');
      } else {
        // Editar tarea existente
        await widget.taskService.editTask(
          widget.task!.id,
          title: title,
          description: description.isEmpty ? null : description,
          priority: _selectedPriority,
        );
        _showSuccessSnackBar('Tarea actualizada correctamente');
      }

      // Regresar a la pantalla anterior
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackBar('Error al guardar la tarea: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  /// Obtiene el color según la prioridad
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

  /// Construye el selector de prioridad
  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prioridad',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: TaskPriority.values.map((priority) {
              return RadioListTile<TaskPriority>(
                title: Text(
                  priority.displayName,
                  style: TextStyle(
                    color: _getPriorityColor(priority),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                secondary: Icon(
                  Icons.circle,
                  color: _getPriorityColor(priority),
                  size: 16,
                ),
                value: priority,
                groupValue: _selectedPriority,
                onChanged: (TaskPriority? value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveTask,
              child: const Text(
                'Guardar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo de título
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título *',
                        hintText: 'Ingresa el título de la tarea',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El título es obligatorio';
                        }
                        if (value.trim().length < 3) {
                          return 'El título debe tener al menos 3 caracteres';
                        }
                        if (value.trim().length > 100) {
                          return 'El título no puede exceder 100 caracteres';
                        }
                        return null;
                      },
                      maxLength: 100,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),

                    // Campo de descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        hintText: 'Ingresa una descripción de la tarea',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value != null && value.trim().length > 500) {
                          return 'La descripción no puede exceder 500 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Selector de prioridad
                    _buildPrioritySelector(),
                    const SizedBox(height: 32),

                    // Botón de guardar (alternativo)
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveTask,
                      icon: Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(isEditing ? 'Actualizar Tarea' : 'Crear Tarea'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón de cancelar
                    OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(height: 50), // Extra space for scroll
                  ],
                ),
              ),
            ),
    );
  }
}