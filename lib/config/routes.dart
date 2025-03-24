import 'package:flutter/material.dart';
import '../models/task.dart';
import '../screens/home_screen.dart';
import '../screens/add_task_screen.dart';
import '../screens/edit_task_screen.dart';

class Routes {
  static const String home = '/';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case addTask:
        return MaterialPageRoute(builder: (_) => const AddTaskScreen());
      
      case editTask:
        final task = settings.arguments as Task;
        return MaterialPageRoute(builder: (_) => EditTaskScreen(task: task));
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}