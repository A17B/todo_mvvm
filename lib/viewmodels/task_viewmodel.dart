import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todoappmvvm/models/task_model.dart';
import 'package:todoappmvvm/services/task_service.dart';
import 'package:uuid/uuid.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _service;
  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  TaskViewModel(this._service) {
    _service.getTasks().listen((data) {
      print('🟢 Tasks updated: ${data.length}');

      _tasks = data;
      notifyListeners();
    });
  }

  Future<String> addTask(
      String title, String description, List<String> sharedWith) async {
    final newTask = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdBy: _service.userId,
      sharedWith: [],
    );
    await _service.addTask(newTask);

    return newTask.id;
  }

  Future<void> updateTask(TaskModel task) async {
    await _service.updateTask(task.id, task.title, task.description);
  }

  Future<void> shareTaskWithOthers(
      String taskId, List<String> sharedWith) async {
    try {
      await _service.shareTaskWithOthers(taskId, sharedWith);
      loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadTasks() async {
    final tasksRef = FirebaseFirestore.instance.collection('tasks');

    final ownTasksStream =
        tasksRef.where('createdBy', isEqualTo: _service.userId).snapshots();

    final sharedTasksStream = tasksRef
        .where('sharedWith', arrayContains: _service.userId)
        .snapshots();

    ownTasksStream.listen((ownSnapshot) {
      final ownTasks = ownSnapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      _tasks = ownTasks;
      notifyListeners();
    });

    sharedTasksStream.listen((sharedSnapshot) {
      final sharedTasks = sharedSnapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      for (var task in sharedTasks) {
        if (!_tasks.any((t) => t.id == task.id)) {
          _tasks.add(task);
        }
      }
      notifyListeners();
    });
  }
}
