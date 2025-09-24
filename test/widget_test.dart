import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/repositories/task_repository.dart';
import 'package:to_do_list_app/services/task_service.dart';

void main() {
  testWidgets('To-Do App loads correctly', (WidgetTester tester) async {
    // Arrange
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final taskRepository = TaskRepository(prefs);
    final taskService = TaskService(taskRepository);

    // Build our app and trigger a frame.
    await tester.pumpWidget(ToDoApp(taskService: taskService));
    
    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that our app loads with the correct title
    expect(find.text('Lista de Tareas'), findsOneWidget);
    
    // Verify that the add button is present
    expect(find.byIcon(Icons.add), findsOneWidget);
    
    // Verify that the empty state message is shown
    expect(find.text('No hay tareas que mostrar'), findsOneWidget);
  });

  testWidgets('Add task button navigates to add screen', (WidgetTester tester) async {
    // Arrange
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final taskRepository = TaskRepository(prefs);
    final taskService = TaskService(taskRepository);

    // Build our app and trigger a frame.
    await tester.pumpWidget(ToDoApp(taskService: taskService));
    await tester.pumpAndSettle();

    // Tap the add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that we navigated to the add task screen
    expect(find.text('Nueva Tarea'), findsOneWidget);
    expect(find.text('Título *'), findsOneWidget);
  });
}
