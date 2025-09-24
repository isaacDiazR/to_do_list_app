import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/repositories/task_repository.dart';
import 'package:to_do_list_app/services/task_service.dart';

/// Pruebas de Caja Negra - Funcionales
/// 
/// Estas pruebas verifican la funcionalidad de la aplicación sin conocer
/// la implementación interna, usando particiones de equivalencia y valores límite.
void main() {
  group('Caja Negra - Pruebas Funcionales', () {
    late TaskService taskService;
    late TaskRepository taskRepository;

    setUp(() async {
      // Configuración limpia para cada test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      taskRepository = TaskRepository(prefs);
      taskService = TaskService(taskRepository);
    });

    group('1. Funcionalidad: Agregar Tareas', () {
      
      test('TC-001: Agregar tarea con título válido (caso normal)', () async {
        // Arrange
        const titulo = 'Comprar comida';
        const descripcion = 'Ir al supermercado';
        const prioridad = TaskPriority.medium;

        // Act
        final resultado = await taskService.addTask(
          title: titulo,
          description: descripcion,
          priority: prioridad,
        );

        // Assert
        expect(resultado, true);
        expect(taskService.tasks.length, 1);
        final tarea = taskService.tasks.first;
        expect(tarea.title, titulo);
        expect(tarea.description, descripcion);
        expect(tarea.priority, prioridad);
        expect(tarea.isCompleted, false);
      });

      test('TC-002: Agregar tarea solo con título (descripción vacía)', () async {
        // Arrange
        const titulo = 'Estudiar Flutter';

        // Act
        final resultado = await taskService.addTask(title: titulo);

        // Assert
        expect(resultado, true);
        expect(taskService.tasks.length, 1);
        final tarea = taskService.tasks.first;
        expect(tarea.title, titulo);
        expect(tarea.description, null);
        expect(tarea.priority, TaskPriority.medium);
      });

      test('TC-003: Agregar tarea con título mínimo (3 caracteres)', () async {
        // Arrange
        const titulo = 'Run'; // Valor límite inferior

        // Act
        final resultado = await taskService.addTask(title: titulo);

        // Assert
        expect(resultado, true);
        expect(taskService.tasks.length, 1);
        expect(taskService.tasks.first.title, titulo);
      });

      test('TC-004: Agregar tarea con título máximo (100 caracteres)', () async {
        // Arrange
        final titulo = 'A' * 100; // Valor límite superior

        // Act
        final resultado = await taskService.addTask(title: titulo);

        // Assert
        expect(resultado, true);
        expect(taskService.tasks.length, 1);
        expect(taskService.tasks.first.title, titulo);
      });

      test('TC-005: Error al agregar tarea con título vacío', () async {
        // Arrange
        const titulo = '';

        // Act & Assert
        expect(
          () => taskService.addTask(title: titulo),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('TC-006: Error al agregar tarea con título solo espacios', () async {
        // Arrange
        const titulo = '   ';

        // Act & Assert
        expect(
          () => taskService.addTask(title: titulo),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('TC-007: Agregar tarea con prioridad alta', () async {
        // Arrange
        const titulo = 'Tarea urgente';
        const prioridad = TaskPriority.high;

        // Act
        await taskService.addTask(title: titulo, priority: prioridad);

        // Assert
        expect(taskService.tasks.first.priority, prioridad);
      });

      test('TC-008: Agregar tarea con prioridad baja', () async {
        // Arrange
        const titulo = 'Tarea opcional';
        const prioridad = TaskPriority.low;

        // Act
        await taskService.addTask(title: titulo, priority: prioridad);

        // Assert
        expect(taskService.tasks.first.priority, prioridad);
      });
    });

    group('2. Funcionalidad: Listar y Filtrar Tareas', () {
      
      test('TC-009: Listar todas las tareas cuando hay múltiples', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea 1', priority: TaskPriority.high);
        await taskService.addTask(title: 'Tarea 2', priority: TaskPriority.medium);
        await taskService.addTask(title: 'Tarea 3', priority: TaskPriority.low);

        // Act
        final tareas = taskService.tasks;

        // Assert
        expect(tareas.length, 3);
        // Las tareas deben estar ordenadas por prioridad (alta primero)
        expect(tareas[0].priority, TaskPriority.high);
        expect(tareas[1].priority, TaskPriority.medium);
        expect(tareas[2].priority, TaskPriority.low);
      });

      test('TC-010: Filtrar tareas por prioridad alta', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea Alta', priority: TaskPriority.high);
        await taskService.addTask(title: 'Tarea Media', priority: TaskPriority.medium);

        // Act
        final tareasAltas = taskService.getTasksByPriority(TaskPriority.high);

        // Assert
        expect(tareasAltas.length, 1);
        expect(tareasAltas.first.title, 'Tarea Alta');
      });

      test('TC-011: Filtrar tareas por prioridad media', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea Alta', priority: TaskPriority.high);
        await taskService.addTask(title: 'Tarea Media', priority: TaskPriority.medium);

        // Act
        final tareasMedias = taskService.getTasksByPriority(TaskPriority.medium);

        // Assert
        expect(tareasMedias.length, 1);
        expect(tareasMedias.first.title, 'Tarea Media');
      });

      test('TC-012: Listar tareas cuando no hay ninguna', () async {
        // Act
        final tareas = taskService.tasks;

        // Assert
        expect(tareas.length, 0);
        expect(tareas.isEmpty, true);
      });
    });

    group('3. Funcionalidad: Editar Tareas', () {
      
      test('TC-013: Editar título de tarea existente', () async {
        // Arrange
        await taskService.addTask(title: 'Título original');
        final tareaId = taskService.tasks.first.id;
        const nuevoTitulo = 'Título modificado';

        // Act
        final resultado = await taskService.editTask(tareaId, title: nuevoTitulo);

        // Assert
        expect(resultado, true);
        expect(taskService.tasks.first.title, nuevoTitulo);
      });

      test('TC-014: Editar descripción de tarea existente', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea', description: 'Descripción original');
        final tareaId = taskService.tasks.first.id;
        const nuevaDescripcion = 'Descripción modificada';

        // Act
        final resultado = await taskService.editTask(tareaId, description: nuevaDescripcion);

        // Assert
        expect(resultado, true);
        expect(taskService.tasks.first.description, nuevaDescripcion);
      });

      test('TC-015: Editar prioridad de tarea existente', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea', priority: TaskPriority.low);
        final tareaId = taskService.tasks.first.id;

        // Act
        final resultado = await taskService.editTask(tareaId, priority: TaskPriority.high);

        // Assert
        expect(resultado, true);
        expect(taskService.tasks.first.priority, TaskPriority.high);
      });

      test('TC-016: Error al editar tarea inexistente', () async {
        // Arrange
        const idInexistente = 'id-que-no-existe';

        // Act & Assert
        expect(
          () => taskService.editTask(idInexistente, title: 'Nuevo título'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('4. Funcionalidad: Eliminar Tareas', () {
      
      test('TC-017: Eliminar tarea existente', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea a eliminar');
        final tareaId = taskService.tasks.first.id;

        // Act
        final resultado = await taskService.deleteTask(tareaId);

        // Assert
        expect(resultado, true);
        expect(taskService.tasks.length, 0);
      });

      test('TC-018: Error al eliminar tarea inexistente', () async {
        // Arrange
        const idInexistente = 'id-que-no-existe';

        // Act & Assert
        expect(
          () => taskService.deleteTask(idInexistente),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('TC-019: Eliminar tarea de múltiples tareas', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea 1');
        await taskService.addTask(title: 'Tarea 2');
        await taskService.addTask(title: 'Tarea 3');
        final tareaIdEliminar = taskService.tasks[1].id;

        // Act
        final resultado = await taskService.deleteTask(tareaIdEliminar);

        // Assert
        expect(resultado, true);
        expect(taskService.tasks.length, 2);
        expect(taskService.tasks.any((t) => t.id == tareaIdEliminar), false);
      });
    });

    group('5. Funcionalidad: Marcar Tareas como Completadas', () {
      
      test('TC-020: Marcar tarea como completada', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea por completar');
        final tareaId = taskService.tasks.first.id;

        // Act
        final resultado = await taskService.toggleTaskCompletion(tareaId);

        // Assert
        expect(resultado, true);
        final tarea = taskService.tasks.first;
        expect(tarea.isCompleted, true);
        expect(tarea.completedAt, isNotNull);
      });

      test('TC-021: Marcar tarea completada como pendiente', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea');
        final tareaId = taskService.tasks.first.id;
        await taskService.toggleTaskCompletion(tareaId); // Completar primero

        // Act
        final resultado = await taskService.toggleTaskCompletion(tareaId);

        // Assert
        expect(resultado, true);
        final tarea = taskService.tasks.first;
        expect(tarea.isCompleted, false);
        expect(tarea.completedAt, isNull);
      });

      test('TC-022: Filtrar solo tareas completadas', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea 1');
        await taskService.addTask(title: 'Tarea 2');
        await taskService.toggleTaskCompletion(taskService.tasks.first.id);

        // Act
        final tareasCompletadas = taskService.getTasksByStatus(isCompleted: true);

        // Assert
        expect(tareasCompletadas.length, 1);
        expect(tareasCompletadas.first.isCompleted, true);
      });

      test('TC-023: Filtrar solo tareas pendientes', () async {
        // Arrange
        await taskService.addTask(title: 'Tarea 1');
        await taskService.addTask(title: 'Tarea 2');
        await taskService.toggleTaskCompletion(taskService.tasks.first.id);

        // Act
        final tareasPendientes = taskService.getTasksByStatus(isCompleted: false);

        // Assert
        expect(tareasPendientes.length, 1);
        expect(tareasPendientes.first.isCompleted, false);
      });

      test('TC-024: Error al marcar tarea inexistente como completada', () async {
        // Arrange
        const idInexistente = 'id-que-no-existe';

        // Act & Assert
        expect(
          () => taskService.toggleTaskCompletion(idInexistente),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}