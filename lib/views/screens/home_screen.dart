import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todoappmvvm/models/task_model.dart';
import 'package:todoappmvvm/viewmodels/task_viewmodel.dart';
import 'package:todoappmvvm/views/widgets/responsive_container.dart';
import 'package:todoappmvvm/views/widgets/task_tile.dart';

import '../../viewmodels/auth_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    print('BUILD AGAIN');
    Future.delayed(Duration.zero, () {
      final taskVM = Provider.of<TaskViewModel>(context, listen: false);
      taskVM.loadTasks(); // ✅ Call loadTasks here
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final taskVM = Provider.of<TaskViewModel?>(context);

    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController shareWithController = TextEditingController();

    void _showShareTaskDialog(String taskId, [task]) {
      final selectedUserIds = <String>{};
      showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Share Task With Others',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('uid', isNotEqualTo: authVM.user!.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No users found to share with.'),
                    );
                  }

                  final users = snapshot.data!.docs;

                  return SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final userId = user.id;
                        final email = user['email'];

                        return CheckboxListTile(
                          value: selectedUserIds.contains(userId),
                          title: Text(email),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                selectedUserIds.add(userId);
                              } else {
                                selectedUserIds.remove(userId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (selectedUserIds.isNotEmpty) {
                      await taskVM?.shareTaskWithOthers(
                          taskId, selectedUserIds.toList());
                    }

                    final text = '''
📌 *Task*: ${task.title}

📝 *Description*:
${task.description}
''';

                    Share.share(text.trim());
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        ),
      );
    }

    void _showCreateTaskDialog() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Create New Task',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter task title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Write a brief description',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                final desc = descController.text.trim();

                if (title.isEmpty || desc.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields")),
                  );
                  return;
                }

                final taskId = await taskVM?.addTask(title, desc, []);
                Navigator.pop(context);

                if (taskId != null) {
                  _showShareTaskDialog(
                    taskId,
                    TaskModel(
                      id: taskId,
                      title: title,
                      description: desc,
                      createdBy: taskId,
                      sharedWith: [],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 2,
        titleSpacing: 16,
        title: Row(
          children: [
            Text(
              'Hi, ${authVM.user!.email!.split('@')[0]}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => authVM.logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            color: Colors.white,
          ),
        ],
      ),
      body: taskVM == null
          ? const Center(child: CircularProgressIndicator())
          : Consumer<TaskViewModel>(builder: (_, taskVM, __) {
              final tasks = taskVM.tasks;
              return tasks.isEmpty
                  ? const Center(child: Text('No tasks available'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ResponsiveContainer(child: TaskTile(task: task));
                      },
                    );
            }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
