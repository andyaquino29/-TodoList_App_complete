import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/todo_tile.dart';
import '../models/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference todos =
      FirebaseFirestore.instance.collection('todos');

  Future<void> _addTodo() async {
    if (_controller.text.trim().isEmpty) return;

    await todos.add({
      'task': _controller.text.trim(),
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  Future<void> _toggleComplete(String id, bool completed) async {
    await todos.doc(id).update({'completed': !completed});
  }

  Future<void> _deleteTodo(String id) async {
    await todos.doc(id).delete();
  }

  Future<void> _editTodo(String id, String oldTask) async {
    final TextEditingController editController =
        TextEditingController(text: oldTask);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await todos.doc(id).update({'task': editController.text});
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'New Task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16)),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: todos.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No tasks yet.'));
                }

                final todoDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: todoDocs.length,
                  itemBuilder: (context, index) {
                    final doc = todoDocs[index];
                    final todo = Todo.fromFirestore(
                        doc.data() as Map<String, dynamic>, doc.id);
                    final formattedDate = todo.createdAt != null
                        ? DateFormat('MMM d, yyyy – hh:mm a')
                            .format(todo.createdAt!)
                        : '';

                    return TodoTile(
                      title: '${todo.task}\n$formattedDate',
                      completed: todo.completed,
                      onToggle: () => _toggleComplete(todo.id, todo.completed),
                      onDelete: () => _deleteTodo(todo.id),
                      onEdit: () => _editTodo(todo.id, todo.task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
