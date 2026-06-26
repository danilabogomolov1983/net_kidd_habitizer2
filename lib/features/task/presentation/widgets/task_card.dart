import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

/// A single task card displayed in the task list.
final class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onComplete,
    required this.onDelete,
  });

  Color _statusColor(TaskStatus status) => switch (status) {
        TaskStatus.todo => Colors.grey,
        TaskStatus.inProgress => Colors.orange,
        TaskStatus.done => Colors.green,
      };

  IconData _priorityIcon(TaskPriority priority) => switch (priority) {
        TaskPriority.high => Icons.priority_high,
        TaskPriority.medium => Icons.arrow_upward,
        TaskPriority.low => Icons.arrow_downward,
      };

  Color _priorityColor(TaskPriority priority) => switch (priority) {
        TaskPriority.high => Colors.red,
        TaskPriority.medium => Colors.amber,
        TaskPriority.low => Colors.blue,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.status == TaskStatus.done;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.circle,
          color: _statusColor(task.status),
          size: 16,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(_priorityIcon(task.priority), size: 14, color: _priorityColor(task.priority)),
                const SizedBox(width: 4),
                Text(task.priority.name, style: theme.textTheme.bodySmall),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.calendar_today, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDone)
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: onComplete,
                tooltip: 'Complete',
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: onTap,
        onLongPress: isDone ? null : () {
          // Could trigger startTask
        },
      ),
    );
  }
}
