class TaskModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final List<String> sharedWith;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.sharedWith,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'createdBy': createdBy,
        'sharedWith': sharedWith,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        createdBy: json['createdBy'],
        sharedWith: List<String>.from(json['sharedWith']),
      );
  static TaskModel fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdBy: map['createdBy'],
      sharedWith: List<String>.from(map['sharedWith']),
    );
  }
}
