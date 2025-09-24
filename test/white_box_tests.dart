import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/repositories/task_repository.dart';
import 'package:to_do_list_app/services/task_service.dart';

/// Pruebas de Caja Blanca - Estructurales
/// 
/// Estas pruebas verifican el código analizando los caminos de ejecución,
/// buscando cobertura de líneas, ramas y condiciones.
void main() {
  group('Caja Blanca - Pruebas Estructurales', () {
    late TaskService taskService;
    late TaskRepository taskRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      taskRepository = TaskRepository(prefs);
      taskService = TaskService(taskRepository);
    });

    group('TaskService - Cobertura de Métodos', () {
      
      test('WB-001: Cobertura del método addTask - camino exitoso', () async {
        // Arrange
        const titulo = 'Test Task';
        
        // Act
        final resultado = await taskService.addTask(title: titulo);
        
        // Assert
        expect(resultado, true);
        expect(taskService.tasks.length, 1);
        
        // Verificar que se ejecutó el trim()
        const tituloConEspacios = '  Test Task  ';
        await taskService.addTask(title: tituloConEspacios);
        expect(taskService.tasks.last.title, 'Test Task');
      });

      test('WB-002: Cobertura del método addTask - validación de título vacío', () async {
        // Arrange & Act & Assert
        expect(
          () => taskService.addTask(title: ''),
          throwsA(predicate((e) => 
            e is ArgumentError && 
            e.message.contains('título de la tarea no puede estar vacío')
          )),
        );
      });

      test('WB-003: Cobertura del método addTask - validación de espacios', () async {
        // Arrange & Act & Assert
        expect(
          () => taskService.addTask(title: '   '),
          throwsA(predicate((e) => 
            e is ArgumentError && 
            e.message.contains('título de la tarea no puede estar vacío')
          )),
        );
      });

      test('WB-004: Cobertura del método editTask - camino exitoso', () async {
        // Arrange
        await taskService.addTask(title: 'Original');
        final taskId = taskService.tasks.first.id;
        
        // Act
        final resultado = await taskService.editTask(taskId, title: 'Edited');
        
        // Assert
        expect(resultado, true);
        expect(taskService.tasks.first.title, 'Edited');
      });

      test('WB-005: Cobertura del método editTask - tarea no encontrada', () async {
        // Arrange & Act & Assert
        expect(
          () => taskService.editTask('invalid-id', title: 'Test'),
          throwsA(predicate((e) => 
            e is ArgumentError && 
            e.message.contains('no encontrada')
          )),
        );
      });

      test('WB-006: Cobertura del método editTask - validación de título', () async {
        // Arrange
        await taskService.addTask(title: 'Original');
        final taskId = taskService.tasks.first.id;
        
        // Act & Assert
        expect(
          () => taskService.editTask(taskId, title: ''),
          throwsA(predicate((e) => 
            e is ArgumentError && 
            e.message.contains('título de la tarea no puede estar vacío')
          )),
        );
      });

      test('WB-007: Cobertura del método deleteTask - camino exitoso', () async {
        // Arrange
        await taskService.addTask(title: 'To Delete');
        final taskId = taskService.tasks.first.id;
        
        // Act
        final resultado = await taskService.deleteTask(taskId);
        
        // Assert
        expect(resultado, true);
        expect(taskService.tasks.length, 0);
      });

      test('WB-008: Cobertura del método deleteTask - tarea no encontrada', () async {
        // Arrange & Act & Assert
        expect(
          () => taskService.deleteTask('invalid-id'),
          throwsA(predicate((e) => 
            e is ArgumentError && 
            e.message.contains('no encontrada')
          )),
        );
      });

      test('WB-009: Cobertura del método toggleTaskCompletion - marcar completada', () async {
        // Arrange
        await taskService.addTask(title: 'Task');
        final taskId = taskService.tasks.first.id;
        
        // Act
        final resultado = await taskService.toggleTaskCompletion(taskId);
        
        // Assert
        expect(resultado, true);
        expect(taskService.tasks.first.isCompleted, true);
        expect(taskService.tasks.first.completedAt, isNotNull);
      });

      test('WB-010: Cobertura del método toggleTaskCompletion - marcar pendiente', () async {
        // Arrange
        await taskService.addTask(title: 'Task');
        final taskId = taskService.tasks.first.id;
        await taskService.toggleTaskCompletion(taskId); // Completar primero
        
        // Act
        final resultado = await taskService.toggleTaskCompletion(taskId);
        
        // Assert
        expect(resultado, true);
        expect(taskService.tasks.first.isCompleted, false);
        expect(taskService.tasks.first.completedAt, isNull);
      });

      test('WB-011: Cobertura del método searchTasks - query vacía', () async {
        // Arrange
        await taskService.addTask(title: 'Task 1');
        await taskService.addTask(title: 'Task 2');
        
        // Act
        final results = taskService.searchTasks('');
        
        // Assert
        expect(results.length, 2);
      });

      test('WB-012: Cobertura del método searchTasks - búsqueda en título', () async {
        // Arrange
        await taskService.addTask(title: 'Flutter Task');
        await taskService.addTask(title: 'Dart Task');
        
        // Act
        final results = taskService.searchTasks('Flutter');
        
        // Assert
        expect(results.length, 1);
        expect(results.first.title, 'Flutter Task');
      });

      test('WB-013: Cobertura del método searchTasks - búsqueda en descripción', () async {
        // Arrange
        await taskService.addTask(title: 'Task', description: 'Flutter development');
        await taskService.addTask(title: 'Task', description: 'Dart coding');
        
        // Act
        final results = taskService.searchTasks('development');
        
        // Assert
        expect(results.length, 1);
        expect(results.first.description, 'Flutter development');
      });

      test('WB-014: Cobertura del método getTaskById - tarea encontrada', () async {
        // Arrange
        await taskService.addTask(title: 'Test Task');
        final taskId = taskService.tasks.first.id;
        
        // Act
        final task = taskService.getTaskById(taskId);
        
        // Assert
        expect(task, isNotNull);
        expect(task!.title, 'Test Task');
      });

      test('WB-015: Cobertura del método getTaskById - tarea no encontrada', () async {
        // Act
        final task = taskService.getTaskById('invalid-id');
        
        // Assert
        expect(task, isNull);
      });

      test('WB-016: Cobertura del getter taskCounts', () async {
        // Arrange
        await taskService.addTask(title: 'Task 1');
        await taskService.addTask(title: 'Task 2');
        await taskService.toggleTaskCompletion(taskService.tasks.first.id);
        
        // Act
        final counts = taskService.taskCounts;
        
        // Assert
        expect(counts['total'], 2);
        expect(counts['completed'], 1);
        expect(counts['pending'], 1);
      });

      test('WB-017: Cobertura del método addMultipleTasks', () async {
        // Arrange
        final tasksData = [
          {'title': 'Task 1', 'priority': TaskPriority.high},
          {'title': 'Task 2', 'priority': TaskPriority.medium},
          {'title': 'Task 3'}, // Sin prioridad (debe usar default)
        ];
        
        // Act
        final resultado = await taskService.addMultipleTasks(tasksData);
        
        // Assert
        expect(resultado, true);
        expect(taskService.tasks.length, 3);
        // Verificar ordenamiento por prioridad
        expect(taskService.tasks[0].priority, TaskPriority.high);
        expect(taskService.tasks[1].priority, TaskPriority.medium);
      });
    });

    group('Task Model - Cobertura de Métodos', () {
      
      test('WB-018: Cobertura del método toggleCompleted', () async {
        // Arrange
        final task = Task(title: 'Test Task');
        expect(task.isCompleted, false);
        expect(task.completedAt, isNull);
        
        // Act - completar
        task.toggleCompleted();
        
        // Assert
        expect(task.isCompleted, true);
        expect(task.completedAt, isNotNull);
        
        // Act - descompletar
        task.toggleCompleted();
        
        // Assert
        expect(task.isCompleted, false);
        expect(task.completedAt, isNull);
      });

      test('WB-019: Cobertura del método copyWith', () async {
        // Arrange
        final original = Task(
          title: 'Original',
          description: 'Original desc',
          priority: TaskPriority.low,
        );
        
        // Act
        final copy = original.copyWith(
          title: 'Modified',
          priority: TaskPriority.high,
        );
        
        // Assert
        expect(copy.id, original.id);
        expect(copy.title, 'Modified');
        expect(copy.description, 'Original desc'); // Sin cambios
        expect(copy.priority, TaskPriority.high);
      });

      test('WB-020: Cobertura del método fromJson', () async {
        // Arrange
        final json = {
          'id': 'test-id',
          'title': 'Test Task',
          'description': 'Test Description',
          'priority': 'Alta',
          'isCompleted': true,
          'createdAt': '2023-01-01T00:00:00.000Z',
          'completedAt': '2023-01-01T01:00:00.000Z',
        };
        
        // Act
        final task = Task.fromJson(json);
        
        // Assert
        expect(task.id, 'test-id');
        expect(task.title, 'Test Task');
        expect(task.description, 'Test Description');
        expect(task.priority, TaskPriority.high);
        expect(task.isCompleted, true);
      });

      test('WB-021: Cobertura del método toJson', () async {
        // Arrange
        final task = Task(
          title: 'Test Task',
          description: 'Test Description',
          priority: TaskPriority.high,
        );
        task.toggleCompleted();
        
        // Act
        final json = task.toJson();
        
        // Assert
        expect(json['title'], 'Test Task');
        expect(json['description'], 'Test Description');
        expect(json['priority'], 'Alta');
        expect(json['isCompleted'], true);
        expect(json['completedAt'], isNotNull);
      });
    });

    group('TaskRepository - Cobertura de Métodos', () {
      
      test('WB-022: Cobertura del método getTasks - sin datos', () async {
        // Act
        final tasks = await taskRepository.getTasks();
        
        // Assert
        expect(tasks, isEmpty);
      });

      test('WB-023: Cobertura del método saveTasks y getTasks', () async {
        // Arrange
        final tasks = [
          Task(title: 'Task 1'),
          Task(title: 'Task 2'),
        ];
        
        // Act
        final saved = await taskRepository.saveTasks(tasks);
        final retrieved = await taskRepository.getTasks();
        
        // Assert
        expect(saved, true);
        expect(retrieved.length, 2);
        expect(retrieved[0].title, 'Task 1');
        expect(retrieved[1].title, 'Task 2');
      });

      test('WB-024: Cobertura del método clearTasks', () async {
        // Arrange
        final tasks = [Task(title: 'Task 1')];
        await taskRepository.saveTasks(tasks);
        
        // Act
        final cleared = await taskRepository.clearTasks();
        final retrieved = await taskRepository.getTasks();
        
        // Assert
        expect(cleared, true);
        expect(retrieved, isEmpty);
      });

      test('WB-025: Cobertura del método getTaskCount', () async {
        // Arrange
        final tasks = [
          Task(title: 'Task 1'),
          Task(title: 'Task 2'),
          Task(title: 'Task 3'),
        ];
        await taskRepository.saveTasks(tasks);
        
        // Act
        final count = await taskRepository.getTaskCount();
        
        // Assert
        expect(count, 3);
      });
    });

    group('TaskPriority Enum - Cobertura', () {
      
      test('WB-026: Cobertura del método fromString - casos válidos', () async {
        // Act & Assert
        expect(TaskPriority.fromString('Alta'), TaskPriority.high);
        expect(TaskPriority.fromString('Media'), TaskPriority.medium);
        expect(TaskPriority.fromString('Baja'), TaskPriority.low);
      });

      test('WB-027: Cobertura del método fromString - caso inválido', () async {
        // Act
        final priority = TaskPriority.fromString('Inválida');
        
        // Assert
        expect(priority, TaskPriority.medium); // Valor por defecto
      });
    });
  });
}