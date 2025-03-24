import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  Map<String, int> _taskCounts = {'total': 0, 'completed': 0, 'pending': 0};
  bool _isLoading = false;
  String _currentFilter = 'all';

  List<Task> get tasks => _getFilteredTasks();
  Map<String, int> get taskCounts => _taskCounts;
  bool get isLoading => _isLoading;
  String get currentFilter => _currentFilter;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await DatabaseHelper.instance.getAllTasks();
      _taskCounts = await DatabaseHelper.instance.getTaskCounts();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final id = await DatabaseHelper.instance.createTask(task);
      final newTask = task.copyWith(id: id);

      _tasks.insert(0, newTask);
      await _updateTaskCounts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await DatabaseHelper.instance.updateTask(task);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }

      await _updateTaskCounts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(int id, bool isCompleted) async {
    try {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        final task = _tasks[index];
        final updatedTask = task.copyWith(
          isCompleted: isCompleted,
          updatedAt: DateTime.now(),
        );

        await DatabaseHelper.instance.updateTask(updatedTask);
        _tasks[index] = updatedTask;

        await _updateTaskCounts();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await DatabaseHelper.instance.deleteTask(id);

      _tasks.removeWhere((task) => task.id == id);
      await _updateTaskCounts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> _updateTaskCounts() async {
    _taskCounts = await DatabaseHelper.instance.getTaskCounts();
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  List<Task> _getFilteredTasks() {
    switch (_currentFilter) {
      case 'completed':
        return _tasks.where((task) => task.isCompleted).toList();
      case 'pending':
        return _tasks.where((task) => !task.isCompleted).toList();
      case 'high':
        return _tasks
            .where((task) => task.priority == TaskPriority.high)
            .toList();
      default:
        return _tasks;
    }
  }
}
