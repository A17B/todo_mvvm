import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoappmvvm/models/task_model.dart';
import 'package:todoappmvvm/viewmodels/task_viewmodel.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  const TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    void _showEditTaskDialog(BuildContext context, TaskModel task) {
      final titleController = TextEditingController(text: task.title);
      final descController = TextEditingController(text: task.description);
      final taskVM = Provider.of<TaskViewModel>(context, listen: false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await taskVM.updateTask(TaskModel(
                    id: task.id,
                    title: titleController.text,
                    description: descController.text,
                    createdBy: task.createdBy,
                    sharedWith: []));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: Icon(
        Icons.task,
        color: Colors.blueAccent,
      ),
      title: Text(
        task.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
      ),
      subtitle: Text(
        task.description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: Colors.grey[600]),
        onPressed: () {
          _showEditTaskDialog(context, task);
        },
      ),
      onTap: () {},
    );
  }
}
