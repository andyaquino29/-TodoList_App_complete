import 'package:flutter/material.dart';

class TodoTile extends StatelessWidget {
  final String title;
  final bool completed;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TodoTile({
    super.key,
    required this.title,
    required this.completed,
    this.onToggle,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(value: completed, onChanged: (_) => onToggle?.call()),
        title: Text(
          title,
          style: TextStyle(
            decoration: completed ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
