class Task {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime createdAt;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.createdAt,
    required this.userId,
  });

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  // Create from Firestore
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      userId: map['userId'] ?? '',
    );
  }
}
