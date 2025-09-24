import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repositories/task_repository.dart';
import 'services/task_service.dart';
import 'screens/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final taskRepository = TaskRepository(prefs);
  final taskService = TaskService(taskRepository);

  runApp(ToDoApp(taskService: taskService));
}

/// Aplicación principal de la lista de tareas
class ToDoApp extends StatelessWidget {
  final TaskService taskService;

  const ToDoApp({
    super.key,
    required this.taskService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: TaskListScreen(taskService: taskService),
    );
  }
}
