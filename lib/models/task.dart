class Task {
  int? id;
  String title;
  String? description;
  DateTime? date;
  bool isCompleted;
  bool isEvent; // Novo campo
  List<String>? categories; // Novo campo

  Task({
    this.id,
    required this.title,
    this.description,
    this.date,
    this.isCompleted = false,
    this.isEvent = false,
    this.categories,
  });

  // Método para converter Task para Map (inserção no SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'isEvent': isEvent ? 1 : 0,
      'categories': categories != null ? categories!.join(',') : null,
    };
  }

  // Método para criar uma Task a partir de um Map (SQLite)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      isCompleted: map['isCompleted'] == 1,
      isEvent: map['isEvent'] == 1,
      categories: map['categories'] != null
          ? (map['categories'] as String).split(',')
          : null,
    );
  }
}
