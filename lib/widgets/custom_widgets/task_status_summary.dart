import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';

class TaskStatusSummary extends StatelessWidget {
  const TaskStatusSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final counts = taskProvider.taskCounts;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusItem(
                    context,
                    'Total',
                    counts['total'] ?? 0,
                    Colors.blue,
                  ),
                  _buildStatusItem(
                    context,
                    'Completed',
                    counts['completed'] ?? 0,
                    Colors.green,
                  ),
                  _buildStatusItem(
                    context,
                    'Pending',
                    counts['pending'] ?? 0,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getIconForLabel(label), color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Total':
        return Icons.task_alt;
      case 'Completed':
        return Icons.check_circle;
      case 'Pending':
        return Icons.pending_actions;
      default:
        return Icons.task_alt;
    }
  }
}
