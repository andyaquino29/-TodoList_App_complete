class Todo {
  final String id;
  final String task;
  final bool completed;
  final DateTime? createdAt;

  Todo({
    required this.id,
    required this.task,
    required this.completed,
    this.createdAt,
  });

  factory Todo.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Todo(
      id: documentId,
      task: data['task'] ?? '',
      completed: data['completed'] ?? false,
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'task': task,
      'completed': completed,
      'createdAt': createdAt,
    };
  }
}
