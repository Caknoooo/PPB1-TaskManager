import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/custom_widgets/task_card.dart';
import '../widgets/custom_widgets/task_status_summary.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final currentFilter = taskProvider.currentFilter;
              String filterText = '';
              Color filterColor = Colors.blue;

              switch (currentFilter) {
                case 'completed':
                  filterText = 'Completed';
                  filterColor = Colors.green;
                  break;
                case 'pending':
                  filterText = 'Pending';
                  filterColor = Colors.orange;
                  break;
                case 'high':
                  filterText = 'High Priority';
                  filterColor = Colors.red;
                  break;
                default:
                  filterText = 'All Tasks';
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  children: [
                    if (currentFilter != 'all')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: filterColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: filterColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              filterText,
                              style: TextStyle(
                                color: filterColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterOptions,
                      tooltip: 'Filter Tasks',
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProvider.tasks.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Custom stateless widget for task status summary
              const TaskStatusSummary(),

              // Task list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => taskProvider.loadTasks(),
                  child: ListView.builder(
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      return TaskCard(
                        task: task,
                        onToggleComplete: (isCompleted) {
                          taskProvider.toggleTaskCompletion(
                            task.id!,
                            isCompleted,
                          );
                        },
                        onEdit: () => _navigateToEditScreen(task),
                        onDelete: () => _confirmDelete(task),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first task by tapping on the + button',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    if (result == true && context.mounted) {
      await Provider.of<TaskProvider>(context, listen: false).loadTasks();
    }
  }

  void _navigateToEditScreen(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)),
    );

    if (result == true && context.mounted) {
      await Provider.of<TaskProvider>(context, listen: false).loadTasks();
    }
  }

  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (context.mounted) {
                    Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    ).deleteTask(task.id!);
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final currentFilter = taskProvider.currentFilter;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Filter Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.list),
                      title: const Text('All Tasks'),
                      selected: currentFilter == 'all',
                      onTap: () {
                        taskProvider.setFilter('all');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: const Text('Completed Tasks'),
                      selected: currentFilter == 'completed',
                      onTap: () {
                        taskProvider.setFilter('completed');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.pending_actions,
                        color: Colors.orange,
                      ),
                      title: const Text('Pending Tasks'),
                      selected: currentFilter == 'pending',
                      onTap: () {
                        taskProvider.setFilter('pending');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.priority_high,
                        color: Colors.red,
                      ),
                      title: const Text('High Priority'),
                      selected: currentFilter == 'high',
                      onTap: () {
                        taskProvider.setFilter('high');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
