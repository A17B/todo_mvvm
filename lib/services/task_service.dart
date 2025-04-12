import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todoappmvvm/models/task_model.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;
  final String userId;

  TaskService(this.userId);

  Stream<List<TaskModel>> getTasks() {
    final sharedWithStream = _db
        .collection('tasks')
        .where('sharedWith', arrayContains: userId)
        .snapshots();

    final createdByStream = _db
        .collection('tasks')
        .where('createdBy', isEqualTo: userId)
        .snapshots();

    return sharedWithStream.asyncMap((sharedSnapshot) async {
      final sharedTasks = sharedSnapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();

      final createdBySnapshot = await createdByStream.first;
      final createdTasks = createdBySnapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .where((task) => !sharedTasks.any((t) => t.id == task.id))
          .toList();

      return [...sharedTasks, ...createdTasks];
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _db.collection('tasks').doc(task.id).set(task.toJson());
  }

  Future<void> updateTask(
      String taskId, String newTitle, String newDescription) async {
    try {
      final taskRef = _db.collection('tasks').doc(taskId);

      // Update task details
      await taskRef.update({
        'title': newTitle,
        'description': newDescription,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  Future<void> shareTaskWithOthers(
      String taskId, List<String> sharedWithIds) async {
    try {
      final taskRef = _db.collection('tasks').doc(taskId);

      await taskRef.update({
        'sharedWith': FieldValue.arrayUnion(sharedWithIds),
      });
      print("Task shared successfully with the new user!");
    } catch (e) {
      throw Exception('Error sharing task: $e');
    }
  }
}
