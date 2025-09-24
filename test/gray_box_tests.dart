import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/repositories/task_repository.dart';
import 'package:to_do_list_app/services/task_service.dart';

/// Pruebas de Caja Gris - Integración y Rendimiento
/// 
/// Estas pruebas combinan el conocimiento de la estructura interna con 
/// pruebas funcionales, validando estados internos, integración entre 
/// componentes y rendimiento del sistema.
void main() {
  group('Caja Gris - Pruebas de Integración y Rendimiento', () {
    late TaskService taskService;
    late TaskRepository taskRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      taskRepository = TaskRepository(prefs);
      taskService = TaskService(taskRepository);
    });

    group('Integración TaskService ↔ TaskRepository', () {
      
      test('GB-001: Integración completa - agregar, persistir y recuperar', () async {
        // Arrange
        const titulo = 'Tarea de integración';
        const descripcion = 'Prueba de persistencia';
        
        // Act - Agregar tarea
        await taskService.addTask(
          title: titulo, 
          description: descripcion,
          priority: TaskPriority.high,
        );
        
        // Verificar estado interno inmediato
        expect(taskService.tasks.length, 1);
        
        // Crear nueva instancia para verificar persistencia
        final nuevoTaskService = TaskService(taskRepository);
        await nuevoTaskService.loadTasks();
        
        // Assert - Verificar persistencia
        expect(nuevoTaskService.tasks.length, 1);
        final tareaRecuperada = nuevoTaskService.tasks.first;
        expect(tareaRecuperada.title, titulo);
        expect(tareaRecuperada.description, descripcion);
        expect(tareaRecuperada.priority, TaskPriority.high);
      });

      test('GB-002: Validación de contadores internos después de operaciones', () async {
        // Arrange & Act
        await taskService.addTask(title: 'Tarea 1');
        await taskService.addTask(title: 'Tarea 2');
        await taskService.addTask(title: 'Tarea 3');
        
        // Marcar una como completada
        await taskService.toggleTaskCompletion(taskService.tasks.first.id);
        
        // Assert - Verificar contadores internos
        final counts = taskService.taskCounts;
        expect(counts['total'], 3);
        expect(counts['completed'], 1);
        expect(counts['pending'], 2);
        
        // Eliminar una tarea
        await taskService.deleteTask(taskService.tasks.last.id);
        
        // Verificar actualización de contadores
        final newCounts = taskService.taskCounts;
        expect(newCounts['total'], 2);
        expect(newCounts['pending'], 1);
      });

      test('GB-003: Estado interno después de eliminar todas las tareas', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea 1');
        await taskService.addTask(title: 'Tarea 2');
        await taskService.addTask(title: 'Tarea 3');
        
        // Act - Eliminar todas las tareas una por una
        final taskIds = taskService.tasks.map((t) => t.id).toList();
        for (final id in taskIds) {
          await taskService.deleteTask(id);
        }
        
        // Assert - Verificar estado interno limpio
        expect(taskService.tasks.length, 0);
        final counts = taskService.taskCounts;
        expect(counts['total'], 0);
        expect(counts['completed'], 0);
        expect(counts['pending'], 0);
        
        // Verificar persistencia del estado vacío
        final nuevoTaskService = TaskService(taskRepository);
        await nuevoTaskService.loadTasks();
        expect(nuevoTaskService.tasks.length, 0);
      });

      test('GB-004: Integridad de datos después de múltiples ediciones', () async {
        // Arrange
        await taskService.addTask(
          title: 'Título original',
          description: 'Descripción original',
          priority: TaskPriority.low,
        );
        final taskId = taskService.tasks.first.id;
        
        // Act - Múltiples ediciones
        await taskService.editTask(taskId, title: 'Título editado 1');
        await taskService.editTask(taskId, description: 'Descripción editada');
        await taskService.editTask(taskId, priority: TaskPriority.high);
        await taskService.editTask(taskId, title: 'Título final');
        
        // Assert - Verificar estado final
        final tarea = taskService.tasks.first;
        expect(tarea.title, 'Título final');
        expect(tarea.description, 'Descripción editada');
        expect(tarea.priority, TaskPriority.high);
        expect(tarea.id, taskId); // ID debe mantenerse
        
        // Verificar persistencia
        final nuevoTaskService = TaskService(taskRepository);
        await nuevoTaskService.loadTasks();
        final tareaRecuperada = nuevoTaskService.tasks.first;
        expect(tareaRecuperada.title, 'Título final');
      });

      test('GB-005: Ordenamiento interno después de agregar tareas con diferentes prioridades', () async {
        // Arrange & Act - Agregar en orden de prioridad mixto
        await taskService.addTask(title: 'Baja 1', priority: TaskPriority.low);
        await taskService.addTask(title: 'Alta 1', priority: TaskPriority.high);
        await taskService.addTask(title: 'Media 1', priority: TaskPriority.medium);
        await taskService.addTask(title: 'Alta 2', priority: TaskPriority.high);
        await taskService.addTask(title: 'Baja 2', priority: TaskPriority.low);
        
        // Assert - Verificar ordenamiento interno
        final tasks = taskService.tasks;
        expect(tasks[0].priority, TaskPriority.high);
        expect(tasks[1].priority, TaskPriority.high);
        expect(tasks[2].priority, TaskPriority.medium);
        expect(tasks[3].priority, TaskPriority.low);
        expect(tasks[4].priority, TaskPriority.low);
        
        // Verificar que el ordenamiento se mantiene después de persistencia
        final nuevoTaskService = TaskService(taskRepository);
        await nuevoTaskService.loadTasks();
        final tasksRecuperadas = nuevoTaskService.tasks;
        expect(tasksRecuperadas[0].priority, TaskPriority.high);
        expect(tasksRecuperadas[1].priority, TaskPriority.high);
      });
    });

    group('Pruebas de Memoria y Rendimiento', () {
      
      test('GB-006: Rendimiento - Agregar 1000 tareas', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();
        const numeroTareas = 1000;
        
        // Act - Agregar tareas de forma eficiente
        final tareasData = List.generate(numeroTareas, (index) => {
          'title': 'Tarea $index',
          'description': 'Descripción de la tarea $index',
          'priority': TaskPriority.values[index % 3],
        });
        
        await taskService.addMultipleTasks(tareasData);
        stopwatch.stop();
        
        // Assert - Verificar resultado y rendimiento
        expect(taskService.tasks.length, numeroTareas);
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Menos de 5 segundos
        
        print('Tiempo para agregar $numeroTareas tareas: ${stopwatch.elapsedMilliseconds}ms');
        
        // Verificar que el ordenamiento funciona con gran cantidad de datos
        final tasks = taskService.tasks;
        for (int i = 0; i < tasks.length - 1; i++) {
          expect(tasks[i].priority.value, greaterThanOrEqualTo(tasks[i + 1].priority.value));
        }
      });

      test('GB-007: Rendimiento - Búsqueda en 1000 tareas', () async {
        // Arrange
        const numeroTareas = 1000;
        final tareasData = List.generate(numeroTareas, (index) => {
          'title': index % 100 == 0 ? 'Tarea especial $index' : 'Tarea normal $index',
          'description': 'Descripción $index',
        });
        
        await taskService.addMultipleTasks(tareasData);
        
        // Act - Búsqueda
        final stopwatch = Stopwatch()..start();
        final resultados = taskService.searchTasks('especial');
        stopwatch.stop();
        
        // Assert
        expect(resultados.length, 10); // 1000/100 = 10 tareas especiales
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Búsqueda rápida
        
        print('Tiempo de búsqueda en $numeroTareas tareas: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('GB-008: Prueba de memoria - Estado después de eliminar 1000 tareas', () async {
        // Arrange - Agregar tareas
        const numeroTareas = 1000;
        final tareasData = List.generate(numeroTareas, (index) => {
          'title': 'Tarea temporal $index',
        });
        
        await taskService.addMultipleTasks(tareasData);
        expect(taskService.tasks.length, numeroTareas);
        
        // Act - Limpiar todas las tareas
        final stopwatch = Stopwatch()..start();
        await taskService.clearAllTasks();
        stopwatch.stop();
        
        // Assert - Verificar limpieza completa
        expect(taskService.tasks.length, 0);
        final counts = taskService.taskCounts;
        expect(counts['total'], 0);
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        
        // Verificar que la memoria se liberó correctamente
        final nuevoTaskService = TaskService(taskRepository);
        await nuevoTaskService.loadTasks();
        expect(nuevoTaskService.tasks.length, 0);
        
        print('Tiempo para limpiar $numeroTareas tareas: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('GB-009: Rendimiento de filtrado por prioridad en dataset grande', () async {
        // Arrange
        const numeroTareas = 2000;
        final tareasData = List.generate(numeroTareas, (index) => {
          'title': 'Tarea $index',
          'priority': TaskPriority.values[index % 3],
        });
        
        await taskService.addMultipleTasks(tareasData);
        
        // Act - Filtrar por cada prioridad
        final stopwatch = Stopwatch()..start();
        
        final altaPrioridad = taskService.getTasksByPriority(TaskPriority.high);
        final mediaPrioridad = taskService.getTasksByPriority(TaskPriority.medium);
        final bajaPrioridad = taskService.getTasksByPriority(TaskPriority.low);
        
        stopwatch.stop();
        
        // Assert
        expect(altaPrioridad.length + mediaPrioridad.length + bajaPrioridad.length, numeroTareas);
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        
        // Verificar distribución aproximadamente igual
        expect(altaPrioridad.length, closeTo(numeroTareas / 3, 50));
        expect(mediaPrioridad.length, closeTo(numeroTareas / 3, 50));
        expect(bajaPrioridad.length, closeTo(numeroTareas / 3, 50));
        
        print('Tiempo de filtrado por prioridad en $numeroTareas tareas: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('GB-010: Persistencia con gran cantidad de datos', () async {
        // Arrange
        const numeroTareas = 500;
        final tareasData = List.generate(numeroTareas, (index) => {
          'title': 'Tarea persistente $index',
          'description': 'Esta es una descripción más larga para la tarea $index que incluye más texto para probar la persistencia de datos grandes',
          'priority': TaskPriority.values[index % 3],
        });
        
        // Act - Agregar y medir tiempo de persistencia
        final stopwatch = Stopwatch()..start();
        await taskService.addMultipleTasks(tareasData);
        stopwatch.stop();
        
        final tiempoGuardado = stopwatch.elapsedMilliseconds;
        
        // Crear nueva instancia y medir tiempo de carga
        stopwatch.reset();
        stopwatch.start();
        final nuevoTaskService = TaskService(taskRepository);
        await nuevoTaskService.loadTasks();
        stopwatch.stop();
        
        final tiempoCarga = stopwatch.elapsedMilliseconds;
        
        // Assert
        expect(nuevoTaskService.tasks.length, numeroTareas);
        expect(tiempoGuardado, lessThan(3000));
        expect(tiempoCarga, lessThan(2000));
        
        // Verificar integridad de algunos datos
        final sortedTasks = nuevoTaskService.tasks;
        expect(sortedTasks.first.title, contains('Tarea persistente'));
        expect(sortedTasks.last.title, contains('Tarea persistente'));
        
        print('Tiempo de guardado: ${tiempoGuardado}ms, Tiempo de carga: ${tiempoCarga}ms');
      });
    });

    group('Validación de Estados Internos', () {
      
      test('GB-011: Estados internos consistentes durante operaciones concurrentes simuladas', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea 1', priority: TaskPriority.high);
        await taskService.addTask(title: 'Tarea 2', priority: TaskPriority.medium);
        await taskService.addTask(title: 'Tarea 3', priority: TaskPriority.low);
        
        final taskId1 = taskService.tasks[0].id;
        final taskId2 = taskService.tasks[1].id;
        
        // Act - Simular operaciones "concurrentes"
        await taskService.toggleTaskCompletion(taskId1);
        await taskService.editTask(taskId2, title: 'Tarea 2 Editada');
        await taskService.addTask(title: 'Tarea 4', priority: TaskPriority.high);
        
        // Assert - Verificar consistencia
        final counts = taskService.taskCounts;
        expect(counts['total'], 4);
        expect(counts['completed'], 1);
        expect(counts['pending'], 3);
        
        // Verificar que el ordenamiento se mantuvo
        final tasks = taskService.tasks;
        expect(tasks.where((t) => t.priority == TaskPriority.high).length, 2);
        expect(tasks.first.priority, TaskPriority.high);
      });

      test('GB-012: Validación de IDs únicos en operaciones masivas', () async {
        // Arrange & Act
        const numeroTareas = 100;
        final tareasData = List.generate(numeroTareas, (index) => {
          'title': 'Tarea $index',
        });
        
        await taskService.addMultipleTasks(tareasData);
        
        // Assert - Verificar unicidad de IDs
        final ids = taskService.tasks.map((t) => t.id).toSet();
        expect(ids.length, numeroTareas); // Todos los IDs deben ser únicos
        
        // Verificar que los IDs no están vacíos
        for (final task in taskService.tasks) {
          expect(task.id.isNotEmpty, true);
          expect(task.id.length, greaterThan(10)); // UUID mínimo
        }
      });

      test('GB-013: Consistencia de timestamps', () async {
        // Arrange
        final startTime = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 10)); // Small delay
        
        // Act
        await taskService.addTask(title: 'Tarea con timestamp');
        final task = taskService.tasks.first;
        
        await Future.delayed(const Duration(milliseconds: 10)); // Small delay
        await taskService.toggleTaskCompletion(task.id);
        final completedTask = taskService.tasks.first;
        
        final endTime = DateTime.now();
        
        // Assert
        expect(task.createdAt.isAfter(startTime), true);
        expect(task.createdAt.isBefore(endTime), true);
        expect(completedTask.completedAt, isNotNull);
        expect(completedTask.completedAt!.isAfter(task.createdAt), true);
        expect(completedTask.completedAt!.isBefore(endTime.add(const Duration(seconds: 1))), true);
      });
    });
  });
}